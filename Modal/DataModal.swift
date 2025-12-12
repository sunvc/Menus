import CoreTransferable
import CryptoKit
import Defaults
import Foundation
import UniformTypeIdentifiers

extension Defaults.Keys {

    static let settingPassword = Key<String>("SettingPassword", default: "")
    static let settingLocalPassword = Key<String>("SettingLocalPassword", default: "")
    static let remoteUpdateURL = Key<String>("remoteUpdateUrl", default: "")
    static let firstStart = Key<Bool>("FirstStart", default: true)
    static let defaultHome = Key<Page>("defaultHome", default: Page.deepseek)
    static let showMenus = Key<Bool>("FirstStartshowMenu", default: false)
    static let giftShow = Key<Bool>("giftShow", default: false)
    static let searchApi = Key<String>("searchApi", default: "")
    static let searchAuth = Key<String>("searchAuth", default: "")
}

extension UTType {
    static var trnExportType = UTType(exportedAs: "com.uuneo.menus.menu")
}

extension SymmetricKey {
    static var trnKey: SymmetricKey {
        let key = "iJUSTINE".data(using: .utf8)!
        let sha256 = SHA256.hash(data: key)
        return .init(data: sha256)
    }
}

extension Date {
    func yyyyMMddhhmmss() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss" // 自定义格式
        return formatter.string(from: self) // 返回格式化的日期字符串
    }
}
