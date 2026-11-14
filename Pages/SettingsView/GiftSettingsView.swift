import Defaults
import RealmSwift
import SwiftUI

struct GiftSettingsView: View {

    @ObservedResults(VipInfoRealmMode.self, sortDescriptor: SortDescriptor(
        keyPath: \VipInfoRealmMode.createDate, ascending: false
    )) var vipGiftlist
    @Default(.giftShow) var giftShow
    @Default(.giftItemList) var giftItems
    @State private var showDelete = false
    @State private var newGiftName = ""
    @State private var giftSyncing = false
    @State private var hasUnsavedGiftChanges = false
    @State private var pendingGiftSave = false
    @State private var giftEditGeneration = 0
    @State private var autoSaveTask: Task<Void, Never>?

    var body: some View {
        List {
            Section {
                // 礼物开关仅管理员可设置
                Defaults.Toggle("礼物领取开关", systemImage: "app.gift.fill", key: .giftShow)
                    .disabled(!MemberAuth.shared.isAdmin)
                    .opacity(MemberAuth.shared.isAdmin ? 1 : 0.5)
            } footer: {
                if !MemberAuth.shared.isAdmin {
                    Text("礼物开关仅管理员可修改")
                }
            }

            if MemberAuth.shared.isAdmin {
                Section {
                    ForEach($giftItems) { $item in
                        HStack {
                            TextField("礼物名称", text: $item.name)
                            Spacer()
                            Toggle("启用", isOn: $item.enabled)
                                .labelsHidden()
                        }
                    }
                    .onDelete { giftItems.remove(atOffsets: $0) }

                    HStack {
                        TextField("新增礼物名称", text: $newGiftName)
                        Button("添加") {
                            addGiftItem()
                        }
                        .buttonStyle(.borderless)
                        .disabled(newGiftName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                } header: {
                    Text("礼物项目")
                } footer: {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("礼物项目用于礼品领取, 停用的项目不生效; 修改后会自动保存")

                        HStack {
                            Button {
                                Task { await syncGiftItems() }
                            } label: {
                                Label(giftSyncing ? "同步中…" : "保存到服务器",
                                      systemImage: "icloud.and.arrow.up")
                            }
                            .buttonStyle(.borderless)
                            .disabled(giftSyncing)

                            Spacer()

                            Button {
                                Task { await pullGiftConfig() }
                            } label: {
                                Label("从服务器刷新", systemImage: "arrow.clockwise")
                            }
                            .buttonStyle(.borderless)
                            .disabled(giftSyncing)
                        }
                    }
                }

            }

            ForEach(vipGiftlist, id: \.id) { value in
                HStack {
                    Text(value.phone)
                    Spacer()
                    Text(value.name)

                    Text(verbatim: "-")

                    Text(value.cardLevel)
                    Spacer()
                    Text(value.createDate.yymm)
                    
                }
                .minimumScaleFactor(0.5)
                .padding()
                .font(.title2)
            }
            .onDelete(perform: $vipGiftlist.remove)
        }
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            if vipGiftlist.count > 0 {
                ToolbarItem {
                    Text("\(vipGiftlist.count)")
                        .padding(.horizontal)
                        .contentShape(Rectangle())
                        .onTapGesture(count: showDelete ? 1 : 5) {
                            self.showDelete.toggle()
                        }
                }
            }

            if !vipGiftlist.isEmpty {
                ToolbarItem(placement: .topBarLeading) {
                    ShareLink(item: exportData())
                }
            }

            if showDelete && !vipGiftlist.isEmpty {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        // TODO: 删除所有数据
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        .task {
            // 管理员进入时只用服务器数据初始化本地为空的配置;
            // 已有本地配置则保留, 避免覆盖还没保存的修改
            guard MemberAuth.shared.isAdmin else { return }
            if giftItems.isEmpty,
               let items = await fetchGiftItemsFromServer(all: true) {
                giftItems = items
            }
        }
        .onChange(of: giftItems) { _, _ in scheduleGiftAutoSave() }
        .onDisappear {
            // 离开设置页时把还没保存的修改立即写回服务器
            autoSaveTask?.cancel()
            guard hasUnsavedGiftChanges else { return }
            Task { await saveGiftConfig(showSuccessToast: false) }
        }
    }

    // MARK: - 礼物项目管理(仅管理员)

    private func addGiftItem() {
        let name = newGiftName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        giftItems.append(GiftItem(name: name))
        newGiftName = ""
    }

    /// 手动保存: 带成功提示
    private func syncGiftItems() async {
        await saveGiftConfig(showSuccessToast: true)
    }

    /// 编辑后自动保存(停顿 1 秒): 防止退出页面后修改丢失
    private func scheduleGiftAutoSave() {
        guard MemberAuth.shared.isAdmin else { return }
        giftEditGeneration += 1
        hasUnsavedGiftChanges = true
        autoSaveTask?.cancel()
        autoSaveTask = Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            guard !Task.isCancelled else { return }
            await saveGiftConfig(showSuccessToast: false)
        }
    }

    /// 全量保存礼物项目到服务器(列表外的项会被删除)
    private func saveGiftConfig(showSuccessToast: Bool) async {
        guard MemberAuth.shared.isAdmin else { return }
        if giftSyncing {
            pendingGiftSave = true
            return
        }
        let generation = giftEditGeneration
        giftSyncing = true
        let saved = await performGiftSave()
        giftSyncing = false

        if saved {
            if generation == giftEditGeneration {
                hasUnsavedGiftChanges = false
            } else {
                // 保存期间又有编辑, 再补一次保存
                pendingGiftSave = true
            }
            if showSuccessToast {
                peacock.shared.toast("礼物设置已保存", mode: .success)
            }
        } else if showSuccessToast || hasUnsavedGiftChanges {
            peacock.shared.toast("同步失败, 请重试", mode: .error)
        }

        if pendingGiftSave {
            pendingGiftSave = false
            await saveGiftConfig(showSuccessToast: false)
        }
    }

    private func performGiftSave() async -> Bool {
        let items: [[String: Any]] = giftItems
            .filter { !$0.name.trimmingCharacters(in: .whitespaces).isEmpty }
            .map { ["giftID": $0.giftID, "name": $0.name, "enabled": $0.enabled] }

        return await postGiftConfig(path: "/ios/gift/items", body: ["items": items])
    }

    private func postGiftConfig(path: String, body: [String: Any]) async -> Bool {
        guard let url = URL(string: MemberAuth.shared.baseURL + path) else { return false }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 15
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(MemberAuth.shared.token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  (json["code"] as? Int) == 200
            else { return false }
            return true
        } catch {
            debugPrint(error)
            return false
        }
    }

    /// 从服务器拉取全部礼物项目(含停用)
    private func pullGiftConfig() async {
        if let items = await fetchGiftItemsFromServer(all: true) {
            giftItems = items
        }
    }

    func exportData() -> String {
        var results = ""
        var index = 0

        for item in vipGiftlist {
            index += 1
            let line = "\(index),\(item.phone),\(item.name),\(item.cardLevel),\(item.createDate.yymm)\n"
            results.append(line)
        }
        return results
    }
}

extension Date {
    var yymm: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: self)
    }

    var yyyy: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: self)
    }
}

