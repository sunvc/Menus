//
//  GiftHomeView.swift
//  PeacockMenus
//
//  Created by He Cho on 2024/10/24.
//

import Alamofire
import Defaults
import RealmSwift
import SwiftUI
import SwiftyJSON

extension Defaults.Keys {
    static let giftsNew = Key<[String: VipInfo]>("gistNewList", default: [:])
    /// 礼物项目本地缓存(远程列表落地, 离线可用)
    static let giftItemList = Key<[GiftItem]>("giftItemList", default: [])
    /// 礼物快捷选项本地缓存(一键选中一组礼物)
    static let giftQuickOptionList = Key<[GiftQuickOption]>("giftQuickOptionList", default: [])
}

/// 礼物项目: 可多选组合, 以 giftID 为唯一标识
struct GiftItem: Codable, Identifiable, Hashable, Defaults.Serializable {
    var giftID: String
    var name: String
    var enabled: Bool = true

    var id: String { giftID }

    enum CodingKeys: String, CodingKey {
        case giftID, name, enabled
    }

    init(giftID: String = UUID().uuidString, name: String, enabled: Bool = true) {
        self.giftID = giftID
        self.name = name
        self.enabled = enabled
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        giftID = try c.decodeIfPresent(String.self, forKey: .giftID) ?? ""
        name = try c.decodeIfPresent(String.self, forKey: .name) ?? ""
        enabled = try c.decodeIfPresent(Bool.self, forKey: .enabled) ?? true
    }
}

/// 礼物快捷选项: 礼物页点一下即同时选中一组礼物
struct GiftQuickOption: Codable, Identifiable, Hashable, Defaults.Serializable {
    var optionID: String
    var name: String
    var giftIDs: [String]

    var id: String { optionID }

    enum CodingKeys: String, CodingKey {
        case optionID, name, giftIDs
    }

    init(optionID: String = UUID().uuidString, name: String, giftIDs: [String] = []) {
        self.optionID = optionID
        self.name = name
        self.giftIDs = giftIDs
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        optionID = try c.decodeIfPresent(String.self, forKey: .optionID) ?? ""
        name = try c.decodeIfPresent(String.self, forKey: .name) ?? ""
        giftIDs = try c.decodeIfPresent([String].self, forKey: .giftIDs) ?? []
    }
}

/// 服务器端礼物列表通用响应(礼物项目 / 快捷选项)
struct GiftListResponse<T: Decodable>: Decodable {
    let code: Int
    let data: [T]?
}

/// 拉取礼物项目: 请求失败返回 nil, 成功返回列表(可能为空)
func fetchGiftItemsFromServer(all: Bool) async -> [GiftItem]? {
    let items: [GiftItem]? = await requestGiftList(
        path: "/ios/gift/items", all: all, retried: false
    )
    guard let items else { return nil }
    return items.filter { !$0.giftID.isEmpty && !$0.name.isEmpty }
}

/// 拉取礼物快捷选项: 请求失败返回 nil, 成功返回列表(可能为空)
func fetchGiftQuickOptionsFromServer() async -> [GiftQuickOption]? {
    let options: [GiftQuickOption]? = await requestGiftList(
        path: "/ios/gift/quick-options", all: false, retried: false
    )
    guard let options else { return nil }
    return options.filter { !$0.optionID.isEmpty && !$0.name.isEmpty }
}

private func requestGiftList<T: Decodable>(
    path: String, all: Bool, retried: Bool
) async -> [T]? {
    guard MemberAuth.shared.isLoggedIn else { return nil }
    var components = URLComponents(string: MemberAuth.shared.baseURL + path)
    if all {
        components?.queryItems = [URLQueryItem(name: "all", value: "1")]
    }
    guard let url = components?.url else { return nil }

    var request = URLRequest(url: url)
    request.timeoutInterval = 15
    request.setValue("Bearer \(MemberAuth.shared.token)", forHTTPHeaderField: "Authorization")

    do {
        let (data, response) = try await URLSession.shared.data(for: request)
        let status = (response as? HTTPURLResponse)?.statusCode
        // token 过期先续签再重试一次
        if status == 401, !retried, await MemberAuth.shared.refresh() {
            return await requestGiftList(path: path, all: all, retried: true)
        }
        guard status == 200,
              let result = try? JSONDecoder().decode(GiftListResponse<T>.self, from: data),
              result.code == 200
        else { return nil }
        return result.data ?? []
    } catch {
        return nil
    }
}

/// 服务器端礼物领取记录
struct GiftClaimRecord: Identifiable, Decodable {
    let id: UInt
    let phone: String
    let name: String
    let cardLevel: String
    let balance: Int
    let cardID: String
    let cardType: String
    let createdAt: String?
    /// 本次赠送的礼物项目, 逗号分隔
    let giftNames: String?

    enum CodingKeys: String, CodingKey {
        case id = "ID", phone, name, balance
        case cardLevel = "cardLevel"
        case cardID = "cardID"
        case cardType = "cardType"
        case createdAt = "CreatedAt"
        case giftNames = "giftNames"
    }
}

/// 领取统计的时间段预设(按天)
enum ClaimRangePreset: String, CaseIterable, Identifiable {
    case today = "今天"
    case week = "近7天"
    case month = "近30天"
    case thisMonth = "本月"
    case thisYear = "今年"
    case custom = "自定义…"

    var id: String { rawValue }
}

/// 统计: 各礼物的领取数量
struct GiftCountItem: Identifiable {
    let id: String
    let name: String
    let count: Int
}

/// 统计: 每天的领取人数
struct DailyClaimCount: Identifiable {
    let id: Date
    let day: Date
    let count: Int
}

/// 服务端时间是 RFC3339, 兼容任意位数的小数秒
func claimDateValue(_ iso: String?) -> Date? {
    guard let iso else { return nil }
    var text = iso
    // 去掉小数秒部分, 避免不同位数导致解析失败
    if let dot = text.firstIndex(of: "."),
       let timezone = text[dot...].firstIndex(where: { $0 == "+" || $0 == "-" || $0 == "Z" }) {
        text.removeSubrange(dot..<timezone)
    }
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime]
    if let date = formatter.date(from: text) { return date }
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter.date(from: iso) ?? isoDateFormatter.date(from: iso)
}

/// 领取时间显示: yyyy-MM-dd HH:mm
func claimTimeText(_ iso: String?) -> String {
    guard let date = claimDateValue(iso) else { return "" }
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    return formatter.string(from: date)
}

struct GiftHomeView: View {
    @State private var searchText: String = ""
    @FocusState private var phoneFocus
    @State private var viplist: [VipInfo] = []
    @State private var claims: [GiftClaimRecord] = []
    @State private var claimingPhone: String?
    @Default(.defaultHome) var defaultHome
    @State private var showGifts = false

    // 领取统计: 全部记录 + 时间段(按天)
    @State private var allClaims: [GiftClaimRecord] = []
    @State private var rangePreset: ClaimRangePreset = .thisYear
    @State private var rangeStart: Date = Calendar.current.date(
        from: Calendar.current.dateComponents([.year], from: Date())
    ) ?? Date()
    @State private var rangeEnd: Date = Date()
    @State private var showRangePicker = false

    private var claimedPhones: Set<String> {
        Set(claims.map(\.phone))
    }

    private var claimsYear: Int { VipInfoRealmMode.YEAR() }

    @State private var searchLoading: Bool = false

    /// 礼物项目(本地缓存), 首次进入从远程拉取
    @Default(.giftItemList) var giftItems
    /// 礼物快捷选项(本地缓存), 在会员卡菜单里选择
    @Default(.giftQuickOptionList) var quickOptions

    private var enabledGiftItems: [GiftItem] {
        giftItems.filter { $0.enabled && !$0.name.isEmpty }
    }

    private var enabledGiftIDs: Set<String> {
        Set(enabledGiftItems.map(\.giftID))
    }

    /// 快捷选项里仍然有效的礼物(过滤掉已删除/停用的)
    private func quickOptionGiftIDs(_ option: GiftQuickOption) -> Set<String> {
        Set(option.giftIDs).intersection(enabledGiftIDs)
    }

    private var availableQuickOptions: [GiftQuickOption] {
        quickOptions.filter { !quickOptionGiftIDs($0).isEmpty }
    }

    /// 本次选中的礼物: 快捷选项与搜索框下方的礼物项目共用, 可再单独增减
    @State private var selectedGiftIDs: Set<String> = []

    private var selectedGiftNames: [String] {
        enabledGiftItems.filter { selectedGiftIDs.contains($0.giftID) }.map(\.name)
    }

    @ObservedResults(
        VipInfoRealmMode.self,
        sortDescriptor: SortDescriptor(
            keyPath: \VipInfoRealmMode.createDate,
            ascending: false
        )
    ) var vipGiftlist

    private enum GiftBackdrop {
        case idle, none, partial, all
    }

    private var backdrop: GiftBackdrop {
        guard !viplist.isEmpty else { return .idle }
        let claimedCount = viplist.filter { claimedPhones.contains($0.phone) }.count
        if claimedCount == 0 { return .none }
        return claimedCount == viplist.count ? .all : .partial
    }

    /// 背景渐变: 按查询结果的领取状态切换
    private var backgroundGradient: LinearGradient {
        let colors: [Color]
        switch backdrop {
        case .idle:
            colors = [Color(hex: "0D1B3E"), Color(hex: "2A4B8D")]
        case .none:
            colors = [Color(hex: "0B5E4F"), Color(hex: "27AE87")]
        case .partial:
            colors = [Color(hex: "8A4B00"), Color(hex: "F2A33A")]
        case .all:
            colors = [Color(hex: "7A1330"), Color(hex: "E2556D")]
        }
        return LinearGradient(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var resultText: String {
        if viplist.isEmpty {
            return searchText.trimmingCharacters(in: .whitespaces).isEmpty
                ? "输入手机号查询会员"
                : "没有查询结果"
        }
        return "查询到 \(viplist.count) 位会员"
    }

    var titlegift: String {
        let diskBool = claims.contains { $0.phone == searchText }

        let lingCount = viplist.filter { item in
            claims.contains { $0.phone == item.phone }
        }.count
        if diskBool {
            return lingCount == viplist.count ? "已领" : "部分"
        } else {
            if viplist.count == 0 {
                return "礼品领取"
            } else {
                switch lingCount {
                case 0:
                    return "未领"
                case viplist.count:
                    return "已领"
                default:
                    return "部分"
                }
            }
        }
    }

    @State private var showGiftList: Bool = false

    var body: some View {
        ZStack {
            // 背景装饰光斑
            Circle()
                .fill(.white.opacity(0.08))
                .frame(width: 560, height: 560)
                .blur(radius: 90)
                .offset(x: -280, y: -320)

            Circle()
                .fill(Palette.blue.opacity(0.22))
                .frame(width: 500, height: 500)
                .blur(radius: 110)
                .offset(x: 310, y: 300)

            Text(titlegift)
                .font(.system(size: 600, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white.opacity(0.22), .white.opacity(0.04)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .minimumScaleFactor(0.5)

            VStack {
                Spacer()
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 20) {
                        ForEach(viplist, id: \.id) { item in
                            VipListView(item: item)
                                .frame(width: 340)
                                .scrollTransition { content, phase in
                                    content.scaleEffect(phase.isIdentity ? 1 : 0.9)
                                        .opacity(phase.isIdentity ? 1 : 0.5)
                                }
                        }
                    }
                    .padding(.horizontal)
                }

                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2)
            }

            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "person.text.rectangle")
                        .font(.subheadline.bold())
                    Text(resultText)
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Capsule().fill(.white.opacity(0.16)))
                .overlay(Capsule().strokeBorder(.white.opacity(0.28), lineWidth: 1))
                .frame(width: 600, alignment: .leading)

                // 搜索框
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.white.opacity(0.4), .white.opacity(0.14)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Image(systemName: searchLoading ? "hourglass" : "phone.fill")
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                            .symbolEffect(.pulse, isActive: searchLoading)
                    }
                    .frame(width: 58, height: 58)

                    TextField("输入手机号码搜索", text: $searchText)
                        .font(.system(size: 34, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .tint(.white)
                        .disabled(searchLoading)
                        .focused($phoneFocus)
                        .submitLabel(.search)
                        .onSubmit {
                            // 每次搜索会员资料都重置礼物选择
                            withAnimation {
                                self.selectedGiftIDs.removeAll()
                            }
                            self.getVipList(search: searchText)
                            self.phoneFocus = false
                        }

                    if searchLoading {
                        ProgressView()
                            .controlSize(.large)
                            .tint(.white)
                    } else if !searchText.isEmpty {
                        Button {
                            withAnimation {
                                self.searchText = ""
                                self.viplist = []
                                self.phoneFocus = false
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        .buttonStyle(.plain)
                    }

                    Button {
                        self.getVipList(search: searchText)
                        self.phoneFocus = false
                    } label: {
                        Text("查询")
                            .font(.title3.bold())
                            .foregroundStyle(Palette.blueDeep)
                            .padding(.horizontal, 22)
                            .frame(height: 52)
                            .background(Capsule().fill(.white))
                    }
                    .buttonStyle(.plain)
                    .disabled(
                        searchLoading
                            || searchText.trimmingCharacters(in: .whitespaces).isEmpty
                    )
                    .opacity(
                        searchLoading
                            || searchText.trimmingCharacters(in: .whitespaces).isEmpty
                            ? 0.55 : 1
                    )
                }
                .padding(.horizontal, 20)
                .frame(width: 600, height: 100)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [.white.opacity(0.7), .white.opacity(0.12)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: .black.opacity(0.18), radius: 24, y: 12)
                .overlay(alignment: .bottom) {
                    if searchLoading {
                        HStack(spacing: 6) {
                            ProgressView().scaleEffect(0.7)
                            Text("正在查询…")
                                .font(.caption.bold())
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(.black.opacity(0.45)))
                        .offset(y: 20)
                    }
                }

                giftSelector
            }.offset(y: -130)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation {
                        peacock.shared.page = defaultHome
                    }
                } label: {
                    Image(systemName: "xmark")
                        .padding(10)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }

            ToolbarItem(placement: .topBarLeading) {
                Button {
                    self.showGiftList.toggle()
                } label: {
                    Image(systemName: "pencil.and.list.clipboard")
                        .padding(10)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }
        }
        .ignoresSafeArea()
        .background(backgroundGradient)
        .sheet(isPresented: $showGiftList) {
            NavigationStack {
                List {
                    Section {
                        NavigationLink {
                            ClaimRecordsList(claims: filteredClaims)
                        } label: {
                            LabeledContent("领取人数", value: "\(statClaimantCount) 人")
                        }
                        LabeledContent("领取记录", value: "\(filteredClaims.count) 条")
                        ForEach(giftCounts) { item in
                            LabeledContent(item.name, value: "\(item.count) 件")
                        }
                        if unrecordedGiftClaimCount > 0 {
                            LabeledContent("未记录礼物", value: "\(unrecordedGiftClaimCount) 条")
                        }
                    } header: {
                        Text("统计")
                    } footer: {
                        Text("统计区间: \(dayText(rangeStart)) ~ \(dayText(rangeEnd)), 点击领取人数查看明细")
                    }

                    Section("每日领取") {
                        if dailyCounts.isEmpty {
                            Text("该时间段没有领取记录")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(dailyCounts) { item in
                                NavigationLink {
                                    ClaimRecordsList(
                                        claims: claims(on: item.day),
                                        title: "\(dayText(item.day)) 领取记录"
                                    )
                                } label: {
                                    HStack {
                                        Text(dayText(item.day))
                                        Spacer()
                                        Text("\(item.count) 人")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }

                }
                .navigationTitle("领取列表")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            ForEach(ClaimRangePreset.allCases) { preset in
                                Button {
                                    if preset == .custom {
                                        showRangePicker = true
                                    } else {
                                        applyRangePreset(preset)
                                    }
                                } label: {
                                    if preset == rangePreset {
                                        Label(preset.rawValue, systemImage: "checkmark")
                                    } else {
                                        Text(preset.rawValue)
                                    }
                                }
                            }
                        } label: {
                            Label(
                                rangePreset == .custom
                                    ? "\(monthDayText(rangeStart))~\(monthDayText(rangeEnd))"
                                    : rangePreset.rawValue,
                                systemImage: "calendar"
                            )
                        }
                    }
                }
                .task { await loadAllClaims() }
                .sheet(isPresented: $showRangePicker) {
                    ClaimRangePicker(start: rangeStart, end: rangeEnd) { start, end in
                        rangeStart = start
                        rangeEnd = end
                        rangePreset = .custom
                    }
                }
            }
        }
        .onAppear {
            Task {
                await loadGiftItems()
                await loadQuickOptions()
                await loadClaims()
            }
        }
    }

    /// 拉取远程礼物项目, 成功后落地为本地缓存, 失败沿用缓存
    private func loadGiftItems() async {
        guard MemberAuth.shared.isLoggedIn else { return }
        // 管理员缓存全部项目(含停用), 员工只拿启用项目
        guard let items = await fetchGiftItemsFromServer(all: MemberAuth.shared.isAdmin) else {
            return
        }
        giftItems = items
    }

    /// 拉取远程快捷选项, 成功后落地为本地缓存, 失败沿用缓存
    private func loadQuickOptions() async {
        guard MemberAuth.shared.isLoggedIn else { return }
        guard let options = await fetchGiftQuickOptionsFromServer() else { return }
        quickOptions = options
    }

    // MARK: - 礼物项目

    /// 搜索框下方的礼物项目: 快捷选项选完后还能单独增减
    private var giftSelector: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "gift.fill")
                    .foregroundStyle(.white)
                Text("礼物项目")
                    .font(.headline)
                    .foregroundStyle(.white)

                if selectedGiftIDs.isEmpty {
                    Text("可单选或多选")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.85))
                } else {
                    Text("已选 \(selectedGiftNames.count)")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                    Button {
                        withAnimation { selectedGiftIDs.removeAll() }
                    } label: {
                        Text("清空")
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(.white.opacity(0.25)))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    if enabledGiftItems.isEmpty {
                        Text("暂无礼物项目")
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.85))
                    } else {
                        ForEach(enabledGiftItems) { item in
                            giftChip(item)
                        }
                    }
                }
                .padding(.horizontal)
                .frame(height: 48)
            }
            .frame(height: 48)
        }
        .frame(width: 600, alignment: .leading)
    }

    private func giftChip(_ item: GiftItem) -> some View {
        let selected = selectedGiftIDs.contains(item.giftID)
        return Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.7)) {
                if selected {
                    selectedGiftIDs.remove(item.giftID)
                } else {
                    selectedGiftIDs.insert(item.giftID)
                }
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                Text(item.name)
                    .font(.title3.bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .foregroundStyle(selected ? .white : .primary)
            .background(
                Capsule().fill(selected ? Palette.blueDeep : Color.white.opacity(0.75))
            )
            .overlay(
                Capsule().strokeBorder(
                    selected ? Palette.blueDeep : Color.white.opacity(0.9),
                    lineWidth: 1.5
                )
            )
            .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    func VipListView(item: VipInfo) -> some View {
        let success = claimedPhones.contains(item.phone)
        let claiming = claimingPhone == item.phone
        let claim = claims.first { $0.phone == item.phone }
        GiftMemberCard(
            item: item,
            success: success,
            claiming: claiming,
            giftItems: enabledGiftItems,
            quickOptions: availableQuickOptions,
            selectedGiftIDs: $selectedGiftIDs,
            claimedGiftNames: claim.map { claimGiftNames($0) } ?? [],
            onClaim: { names in
                Task { await claimGift(item: item, giftNames: names) }
            }
        )
        .id(item.phone)
    }

    func getVipList(search: String) {
        // 统一走会员服务器认证接口, 不再单独配置地址/key
        guard MemberAuth.shared.isLoggedIn else {
            searchLoading = false
            peacock.shared.toast("请先登录", mode: .error)
            return
        }
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(MemberAuth.shared.token)"
        ]
        searchLoading = true

        AF.request(
            MemberAuth.shared.baseURL + "/ios/gift",
            method: .get,
            parameters: ["text": search, "page": 1],
            headers: headers
        ).response { response in
            switch response.result {
            case .success(let result):
                if let result = result, let json = try? JSON(data: result) {
                    self.viplist = dataHandler(data: json)
                    // 搜索结果出来后同步一次领取状态
                    Task { await loadClaims() }
                }

            case .failure(let err):
                debugPrint(err.localizedDescription)
            }

            self.searchLoading = false
        }
    }

    private func authHeaders() -> HTTPHeaders {
        ["Authorization": "Bearer \(MemberAuth.shared.token)"]
    }

    /// 加载当年已领取记录; 首次同时迁移本地旧记录并删除
    private func loadClaims() async {
        guard MemberAuth.shared.isLoggedIn else { return }
        let (list, _, _, _): ([GiftClaimRecord], Int?, Int?, Int?) = await memberFetchAsync(
            "/ios/gifts",
            parameters: ["year": String(claimsYear)]
        )
        claims = list
        await migrateLocalClaims()
    }

    /// 本地历史领取记录批量上传, 成功后删除本地数据
    private func migrateLocalClaims() async {
        let local = vipGiftlist.filter { $0.year == claimsYear }
        guard !local.isEmpty else { return }
        let items = local.map {
            [
                "phone": $0.phone,
                "name": $0.name,
                "cardLevel": $0.cardLevel,
                "balance": $0.balance,
                "cardID": $0.cardID,
                "cardType": $0.cardType,
            ] as [String: Any]
        }
        let url = MemberAuth.shared.baseURL + "/ios/gift/batch"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(MemberAuth.shared.token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["items": items])
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if (response as? HTTPURLResponse)?.statusCode == 200 {
                let phones = Set(local.map(\.phone))
                let toDelete = Array(vipGiftlist.filter { phones.contains($0.phone) })
                if let realm = toDelete.first?.realm {
                    try? realm.write {
                        realm.delete(toDelete)
                    }
                }
            }
        } catch {
            debugPrint(error)
        }
    }

    /// 原子领取: 服务端按(手机号,年)唯一约束, 返回 claimed=true 表示已领过
    private func claimGift(item: VipInfo, giftNames: [String]) async {
        claimingPhone = item.phone
        defer { claimingPhone = nil }
        let url = MemberAuth.shared.baseURL + "/ios/gift"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(MemberAuth.shared.token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "phone": item.phone,
            "name": item.name,
            "cardLevel": item.cardLevel,
            "balance": item.balance,
            "cardID": item.cardID,
            "cardType": item.cardType,
            "gifts": giftNames,
        ])
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                peacock.shared.toast("领取失败, 请重试", mode: .error)
                return
            }
            struct ClaimResult: Decodable { let claimed: Bool? }
            if let result = try? JSONDecoder().decode(ClaimResult.self, from: data) {
                await loadClaims()
                // 领取完成(含已领过)后取消所有礼物选择
                withAnimation {
                    selectedGiftIDs.removeAll()
                }
                if result.claimed == true {
                    peacock.shared.toast("已领取过", mode: .light)
                } else {
                    peacock.shared.toast("🎁 领取成功", mode: .success)
                }
            }
        } catch {
            debugPrint(error)
            peacock.shared.toast("网络异常, 请重试", mode: .error)
        }
    }

    // MARK: - 领取统计

    /// 当前时间段内的领取记录(按天, 含起止两天)
    private var filteredClaims: [GiftClaimRecord] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: rangeStart)
        let end = calendar.date(
            byAdding: .day, value: 1, to: calendar.startOfDay(for: rangeEnd)
        ) ?? rangeEnd
        return allClaims.filter { claim in
            guard let date = claimDateValue(claim.createdAt) else { return false }
            return date >= start && date < end
        }
    }

    /// 领取人数(按手机号去重)
    private var statClaimantCount: Int {
        Set(filteredClaims.map(\.phone)).count
    }

    /// 各礼物的领取数量
    private var giftCounts: [GiftCountItem] {
        var counts: [String: Int] = [:]
        for claim in filteredClaims {
            for name in claimGiftNames(claim) {
                counts[name, default: 0] += 1
            }
        }
        return counts
            .sorted { $0.value == $1.value ? $0.key < $1.key : $0.value > $1.value }
            .map { GiftCountItem(id: $0.key, name: $0.key, count: $0.value) }
    }

    private var unrecordedGiftClaimCount: Int {
        filteredClaims.filter { claimGiftNames($0).isEmpty }.count
    }

    /// 每天领取人数(按手机号去重), 新的在前
    private var dailyCounts: [DailyClaimCount] {
        let calendar = Calendar.current
        var phonesByDay: [Date: Set<String>] = [:]
        for claim in filteredClaims {
            guard let date = claimDateValue(claim.createdAt) else { continue }
            phonesByDay[calendar.startOfDay(for: date), default: []].insert(claim.phone)
        }
        return phonesByDay
            .map { DailyClaimCount(id: $0.key, day: $0.key, count: $0.value.count) }
            .sorted { $0.day > $1.day }
    }

    /// 某一天的领取记录
    private func claims(on day: Date) -> [GiftClaimRecord] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: day)
        let end = calendar.date(byAdding: .day, value: 1, to: start) ?? day
        return filteredClaims.filter { claim in
            guard let date = claimDateValue(claim.createdAt) else { return false }
            return date >= start && date < end
        }
    }

    private func claimGiftNames(_ claim: GiftClaimRecord) -> [String] {
        (claim.giftNames ?? "")
            .split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    private func dayText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func monthDayText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd"
        return formatter.string(from: date)
    }

    private func applyRangePreset(_ preset: ClaimRangePreset) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        switch preset {
        case .today:
            rangeStart = today
        case .week:
            rangeStart = calendar.date(byAdding: .day, value: -6, to: today) ?? today
        case .month:
            rangeStart = calendar.date(byAdding: .day, value: -29, to: today) ?? today
        case .thisMonth:
            rangeStart = calendar.date(
                from: calendar.dateComponents([.year, .month], from: Date())
            ) ?? today
        case .thisYear:
            rangeStart = calendar.date(
                from: calendar.dateComponents([.year], from: Date())
            ) ?? today
        case .custom:
            break
        }
        rangeEnd = Date()
        rangePreset = preset
    }

    /// 领取列表统计: 拉取全部年份的领取记录
    private func loadAllClaims() async {
        guard MemberAuth.shared.isLoggedIn else { return }
        let (list, _, _, _): ([GiftClaimRecord], Int?, Int?, Int?) =
            await memberFetchAsync("/ios/gifts", parameters: ["all": "1"])
        allClaims = list
        if allClaims.isEmpty {
            // 拉取失败时退回当年记录, 保证有数据可看
            allClaims = claims
        }
    }

    func dataHandler(data: JSON) -> [VipInfo] {
        //		debugPrint(data["data"]["data"])

        let vipList = data["data"]["data"]

        var result: [VipInfo] = []

        for (_, item) in vipList {
            let balance = item["info"]["balance"].rawValue as? Int ?? 0
            let cardLevel = item["cardLevel"].rawValue as? String ?? ""
            let name = item["name"].rawValue as? String ?? ""
            let cardID = item["card"].rawValue as? String ?? ""
            let cardType = item["cardType"].rawValue as? String ?? ""
            let phone = item["phone"].rawValue as? String ?? ""
            debugPrint(item)
            if cardType == "4" || cardType == "8" || cardType == "11", phone != "" {
                result
                    .append(
                        VipInfo(
                            name: name,
                            cardLevel: cardLevel,
                            balance: balance,
                            cardID: cardID,
                            cardType: cardType,
                            phone: phone,
                            date: vipGiftlist.first(where: { $0.phone == phone })?.createDate
                        )
                    )
            }
        }

        return result
    }

    func createDate(_ date: Date?) -> String {
        var date2: Date { date ?? Date() }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: date2)
    }
}

struct VipInfo: Codable, Defaults.Serializable {
    var id: String = UUID().uuidString
    var name: String
    var cardLevel: String
    var balance: Int
    var cardID: String
    var cardType: String
    var phone: String
    var date: Date?
    var isGift: Bool = false
}

/// 礼品会员卡: 会员信息 + 领取按钮, 领取成功打勾动画
struct GiftMemberCard: View {
    let item: VipInfo
    let success: Bool
    let claiming: Bool
    /// 可用的礼物项目(用于把快捷选项换算成名称)
    let giftItems: [GiftItem]
    /// 快捷选项: 点卡片上的「选择礼物」弹出菜单选择
    let quickOptions: [GiftQuickOption]
    /// 本次选中的礼物(与搜索框下方的礼物项目共用)
    @Binding var selectedGiftIDs: Set<String>
    /// 已领取时, 服务端记录的领取礼物
    let claimedGiftNames: [String]
    let onClaim: ([String]) -> Void

    @State private var checkScale: CGFloat = 0.1
    @State private var cardScale: CGFloat = 1

    private var enabledGiftItemIDs: Set<String> {
        Set(giftItems.map(\.giftID))
    }

    private func quickOptionGiftIDs(_ option: GiftQuickOption) -> Set<String> {
        Set(option.giftIDs).intersection(enabledGiftItemIDs)
    }

    private var selectedOption: GiftQuickOption? {
        guard !selectedGiftIDs.isEmpty else { return nil }
        return quickOptions.first { quickOptionGiftIDs($0) == selectedGiftIDs }
    }

    private func giftNames(for option: GiftQuickOption) -> [String] {
        option.giftIDs.compactMap { giftID in
            giftItems.first { $0.giftID == giftID }?.name
        }
    }

    /// 当前选中的礼物名称(快捷选项选中后可能再手动增减)
    private var currentGiftNames: [String] {
        giftItems.filter { selectedGiftIDs.contains($0.giftID) }.map(\.name)
    }

    var body: some View {
        VStack(spacing: 0) {
            // 顶部: 等级 + 领取状态
            HStack(alignment: .firstTextBaseline) {
                Text(item.cardLevel)
                    .font(.system(size: 34, weight: .black, design: .rounded))
                Spacer()
                Text(success ? "已领取" : "待领取")
                    .font(.caption.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(.white.opacity(0.22)))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.top, 16)

            // 手机号
            HStack(spacing: 6) {
                Image(systemName: "phone.fill")
                    .font(.caption)
                    .opacity(0.8)
                Text(item.phone)
                    .font(.title3.bold())
                    .monospacedDigit()
                Spacer()
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.top, 6)

            // 会员信息玻璃块
            VStack(spacing: 8) {
                infoRow("会员姓名", item.name, font: .headline)
                infoRow("卡号", item.cardID, font: .subheadline.monospacedDigit())
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.white.opacity(0.10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(.white.opacity(0.14), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 14)
            .padding(.top, 12)

            // 选择礼物: 点击弹出快捷选项菜单(已领取的卡不再显示)
            if !success && !quickOptions.isEmpty {
                Menu {
                    // 每个快捷选项单独一个 Section, 菜单里分组显示
                    ForEach(quickOptions) { option in
                        Section {
                            let names = giftNames(for: option)
                            Button {
                                selectedGiftIDs = quickOptionGiftIDs(option)
                            } label: {
                                if selectedOption?.optionID == option.optionID {
                                    Label(
                                        "\(option.name)（\(names.count)件）",
                                        systemImage: "checkmark"
                                    )
                                } else {
                                    Text("\(option.name)（\(names.count)件）")
                                }
                            }
                        }
                    }

                    if !selectedGiftIDs.isEmpty {
                        Section {
                            Button(role: .destructive) {
                                selectedGiftIDs.removeAll()
                            } label: {
                                Text("清除礼物选择")
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "gift.fill")
                        Text(
                            selectedOption?.name
                                ?? (currentGiftNames.isEmpty ? "选择礼物" : "自定义组合")
                        )
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        if !currentGiftNames.isEmpty {
                            Text("· \(currentGiftNames.count)件")
                                .font(.caption.bold())
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        Spacer()
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption.bold())
                            .opacity(0.8)
                    }
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(.white.opacity(0.14)))
                    .overlay(Capsule().strokeBorder(.white.opacity(0.28), lineWidth: 1))
                }
                .disabled(success || claiming)
                .padding(.horizontal, 14)
                .padding(.top, 10)
            }

            // 礼品详情: 已领取显示服务端记录的礼物, 未领取显示本次选择的礼物
            let displayedGiftNames = success ? claimedGiftNames : currentGiftNames
            if !displayedGiftNames.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "gift.fill")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.top, 2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(success ? "领取礼物" : "本次礼物")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                        Text(displayedGiftNames.joined(separator: "、"))
                            .font(.subheadline.bold())
                            .foregroundStyle(.white)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 0)
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.white.opacity(0.10))
                )
                .padding(.horizontal, 14)
                .padding(.top, 10)
            }

            // 领取按钮
            Button {
                onClaim(currentGiftNames)
            } label: {
                HStack(spacing: 8) {
                    if claiming {
                        ProgressView()
                            .tint(success ? .white : Palette.blueDeep)
                    } else if success {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                            .scaleEffect(checkScale)
                        Text("已领取")
                            .font(.headline)
                    } else {
                        Image(systemName: "gift.fill")
                            .font(.headline)
                        Text("点击领取")
                            .font(.title3.bold())
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
            }
            .buttonStyle(.plain)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(success ? Color.white.opacity(0.16) : Color.white)
            )
            .foregroundStyle(success ? .white : Palette.blueDeep)
            .disabled(success || claiming || currentGiftNames.isEmpty)
            .opacity(currentGiftNames.isEmpty && !success ? 0.55 : 1)
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 12)
        }
        .background(
            ZStack {
                LinearGradient(
                    colors: success
                        ? [Color(hex: "E2556D"), Color(hex: "8E1B3A")]
                        : [Color(hex: "3C82F6"), Color(hex: "16305E")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                LinearGradient(
                    colors: [.white.opacity(0.18), .clear],
                    startPoint: .top,
                    endPoint: .center
                )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(.white.opacity(0.22), lineWidth: 1)
        )
        .overlay(alignment: .bottomTrailing) {
            Image(systemName: "gift.fill")
                .font(.system(size: 96))
                .foregroundStyle(.white.opacity(0.07))
                .padding(.trailing, 10)
                .padding(.bottom, 60)
                .allowsHitTesting(false)
        }
        .shadow(
            color: (success ? Color(hex: "8E1B3A") : Palette.blueDeep).opacity(0.35),
            radius: 18, y: 10
        )
        .scaleEffect(cardScale)
        .animation(.spring(response: 0.35, dampingFraction: 0.6), value: cardScale)
        .onChange(of: success) { _, isSuccess in
            if isSuccess {
                // 成功: 卡片弹一下 + 打勾弹入
                cardScale = 1.06
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    cardScale = 1
                }
                withAnimation(.spring(response: 0.4, dampingFraction: 0.45)) {
                    checkScale = 1
                }
            } else {
                checkScale = 0.1
            }
        }
    }

    private func infoRow(_ title: String, _ value: String, font: Font) -> some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
            Spacer()
            Text(value)
                .font(font)
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
    }
}

#Preview {
    GiftHomeView()
        .ignoresSafeArea()
}

/// 自定义统计时间段: 按天选择起止日期
struct ClaimRangePicker: View {
    let onApply: (Date, Date) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var start: Date
    @State private var end: Date

    init(start: Date, end: Date, onApply: @escaping (Date, Date) -> Void) {
        _start = State(initialValue: start)
        _end = State(initialValue: end)
        self.onApply = onApply
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("开始日期", selection: $start, displayedComponents: .date)
                    DatePicker("结束日期", selection: $end, in: start..., displayedComponents: .date)
                } footer: {
                    Text("按天统计, 包含起止这两天")
                }
            }
            .navigationTitle("选择时间段")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("确定") {
                        let calendar = Calendar.current
                        let startDay = calendar.startOfDay(for: min(start, end))
                        let endDay = calendar.startOfDay(for: max(start, end))
                        onApply(startDay, endDay)
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}


/// 领取记录明细: 从领取列表点「领取记录」进入
struct ClaimRecordsList: View {
    let claims: [GiftClaimRecord]
    var title: String = "领取记录"

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                if claims.isEmpty {
                    Text("该时间段没有领取记录")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                } else {
                    ForEach(claims) { value in
                        recordCard(value)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle(title)
        .toolbar {
            if !claims.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Text("\(claims.count) 条")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    /// 单条领取明细卡片
    private func recordCard(_ value: GiftClaimRecord) -> some View {
        let gifts = giftNameList(value)
        return HStack(alignment: .top, spacing: 12) {
            // 头像色块(按姓名取渐变色)
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: Palette.gradient(
                                for: value.name.isEmpty ? value.phone : value.name
                            ),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Text(String((value.name.isEmpty ? value.phone : value.name).prefix(1)))
                    .font(.headline.bold())
                    .foregroundStyle(.white)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline) {
                    Text(value.phone)
                        .font(.headline.bold())
                    Spacer()
                    HStack(spacing: 3) {
                        Image(systemName: "clock")
                            .font(.caption2)
                        Text(claimTimeOnlyText(value.createdAt))
                            .font(.subheadline.monospacedDigit())
                    }
                    .foregroundStyle(.secondary)
                }

                HStack(spacing: 6) {
                    Text(value.name)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if !value.cardLevel.isEmpty {
                        Text(value.cardLevel)
                            .font(.caption.bold())
                            .foregroundStyle(Palette.blueDeep)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(Palette.blueDeep.opacity(0.14)))
                    }

                    Spacer(minLength: 0)
                }

                if !gifts.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "gift.fill")
                            .font(.caption)
                        Text(gifts.joined(separator: "、"))
                            .font(.footnote.bold())
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        Spacer(minLength: 0)
                    }
                    .foregroundStyle(Palette.orange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Palette.orange.opacity(0.12))
                    )
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
        .overlay(alignment: .leading) {
            // 左侧装饰色条
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Palette.blue, Palette.blueDeep],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 4)
                .padding(.vertical, 14)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
    }

    private func giftNameList(_ value: GiftClaimRecord) -> [String] {
        (value.giftNames ?? "")
            .split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    /// 明细里只显示时间(HH:mm), 日期由页面标题体现
    private func claimTimeOnlyText(_ iso: String?) -> String {
        guard let date = claimDateValue(iso) else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
