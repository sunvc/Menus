import Defaults
import SwiftUI
import TipKit

struct AppSettings: View {
    @Default(.homeCardTitle) var homeCardTitle
    @Default(.homeCardSubTitle) var homeCardSubTitle
    @Default(.homeItemsTitle) var homeItemsTitle
    @Default(.homeItemsSubTitle) var homeItemsSubTitle
    @Default(.settingPassword) var settingPassword
    @Default(.settingLocalPassword) var settingLocalPassword
    @Default(.remoteUpdateURL) var remoteUpdateURL
    @Default(.menusName) var menusName
    @Default(.menusSubName) var subName
    @Default(.menusFooter) var menusFooter
    @Default(.menusImage) var menusImage

    @Default(.defaultHome) var defaultHome

    @EnvironmentObject var manager: peacock

    @State private var passwd: String = ""
    let editTip = EditChangeTipView()

    var body: some View {
        List {
            TipView(editTip)

            Section {
                TextField("自动同步地址", text: $remoteUpdateURL)
                    .customField(icon: "link", data: $remoteUpdateURL)
                    .disabled(settingPassword != settingLocalPassword)

            } header: {
                Label("自动同步地址", systemImage: "link")
            } footer: {
                Text("服务器必须实现GET和POST方法，GET方法返回JSON数据，POST方法接收JSON文件")
            }
            .onChange(of: remoteUpdateURL) { _, newValue in
                if let url = URL(string: newValue) {
                    manager
                        .updateItem(url: url.absoluteString, toast: true) { success in
                            if success {
                                Defaults[.defaultHome] = .home
                                Defaults[.showMenus] = true
                                manager.page = .home
                            }
                        }
                }
            }

            Section {
                SecureField("输入密码", text: $settingLocalPassword)
                    .customField(icon: "lock", data: $settingLocalPassword)

            } header: {
                Label("校验密码", systemImage: "lock")
            }

            if defaultHome == .home {
                Section {
                    TextField("菜单标题", text: $menusName)
                        .customField(icon: "pencil", data: $menusName)
                } header: {
                    Label("菜单标题", systemImage: "doc.text")
                }

                Section {
                    TextField("子菜单标题", text: $subName)
                        .customField(icon: "pencil", data: $subName)
                } header: {
                    Label("子菜单标题", systemImage: "doc.text")
                }

                Section {
                    TextField("菜单底部", text: $menusFooter)
                        .customField(icon: "pencil", data: $menusFooter)
                } header: {
                    Label("菜单底部", systemImage: "doc.text")
                }

                Section {
                    TextField("菜单图标", text: $menusImage)
                        .customField(icon: "photo", data: $menusImage)

                } header: {
                    Label("菜单图标", systemImage: "photo")
                }

                Section {
                    TextField("会员卡标题", text: $homeCardTitle)
                        .customField(icon: "pencil", data: $homeCardTitle)
                } header: {
                    Label("会员卡标题", systemImage: "person.text.rectangle")
                }

                Section {
                    TextField("会员卡副标题", text: $homeCardSubTitle)
                        .customField(icon: "pencil", data: $homeCardSubTitle)
                } header: {
                    Label("会员卡副标题", systemImage: "person.text.rectangle")
                }

                Section {
                    TextField("项目标题", text: $homeItemsTitle)
                        .customField(icon: "pencil", data: $homeItemsTitle)
                } header: {
                    Label("项目标题", systemImage: "doc.text")
                }

                Section {
                    TextField("项目副标题", text: $homeItemsSubTitle)
                        .customField(icon: "pencil", data: $homeItemsSubTitle)
                } header: {
                    Label("项目副标题", systemImage: "doc.text")
                }
            }
        }
        .toolbar {
            ToolbarItem {
                Button {
                    manager.fullPage = true
                } label: {
                    Image(systemName: "qrcode.viewfinder")
                }
            }
        }
    }
}

#Preview {
    AppSettings()
        .environmentObject(peacock.shared)
}
