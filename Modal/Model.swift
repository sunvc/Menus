//
//  Model.swift
//  PeacockMenus
//
//  Created by Neo on 2025/11/25.
//
import CoreTransferable
import Foundation
import RealmSwift
import UniformTypeIdentifiers

class CategoryRealmData: Object, ObjectKeyIdentifiable, Codable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var title: String = String(localized: "新项目")
    @Persisted var subTitle: String = ""
    @Persisted var image: String = "haircut"
    @Persisted var color: String = "background11"
    @Persisted var sort: Int = 0

    static func create(
        id: String = UUID().uuidString,
        title: String = String(localized: "新项目"),
        subTitle: String = "",
        image: String = "haircut",
        color: String = "background11",
        sort: Int = 0
    ) -> CategoryRealmData {
        let data = CategoryRealmData()
        data.id = id
        data.title = title
        data.subTitle = subTitle
        data.image = image
        data.color = color
        data.sort = sort
        return data
    }

    func copyID() -> CategoryRealmData {
        let newData = CategoryRealmData()
        newData.id = UUID().uuidString
        newData.title = title
        newData.subTitle = subTitle
        newData.image = image
        newData.color = color
        newData.sort = sort
        return newData
    }
}

class MemberCardRealmData: Object, ObjectKeyIdentifiable, Codable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var title: String = String(localized: "新卡")
    @Persisted var subTitle: String = ""
    @Persisted var money: Int = 0
    @Persisted var name: String = String(localized: "原价")
    @Persisted var discount: Double = 1
    @Persisted var discount2: Double = 1
    @Persisted var image: String = "peacock4"
    @Persisted var footer: String = ""
    @Persisted var sort: Int = 0

    static var nonmember: MemberCardRealmData {
        let data = MemberCardRealmData()
        data.id = "CF8A750D-42D6-44B2-91AA-83BB9A99AAE0"
        data.title = String(localized: "非会员")
        data.name = String(localized: "原价")
        return data
    }

    static func create(
        id: String = UUID().uuidString,
        title: String = String(localized: "新卡"),
        subTitle: String = "",
        money: Int = 0,
        name: String = String(localized: "原价"),
        discount: Double = 1,
        discount2: Double = 1,
        image: String = "peacock4",
        footer: String = "",
        sort: Int = 0
    ) -> MemberCardRealmData {
        let data = MemberCardRealmData()
        data.id = id
        data.title = title
        data.subTitle = subTitle
        data.money = money
        data.name = name
        data.discount = discount
        data.discount2 = discount2
        data.image = image
        data.footer = footer
        data.sort = sort
        return data
    }

    func copyID() -> MemberCardRealmData {
        let data = MemberCardRealmData()
        data.id = UUID().uuidString // 新主键
        data.title = title
        data.subTitle = subTitle
        data.money = money
        data.name = name
        data.discount = discount
        data.discount2 = discount2
        data.image = image
        data.footer = footer
        data.sort = sort
        return data
    }
}

class SubCategoryRealmData: Object, ObjectKeyIdentifiable, Codable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var categoryID: String = ""
    @Persisted var title: String = String(localized: "新项目")
    @Persisted var subTitle: String = ""
    @Persisted var footer: String = ""
    @Persisted var sort: Int = 0

    static func create(
        id: String = UUID().uuidString,
        categoryID: String = "",
        title: String = "",
        subTitle: String = "",
        footer: String = "",
        sort: Int = 0
    ) -> SubCategoryRealmData {
        let data = SubCategoryRealmData()
        data.id = id
        data.categoryID = categoryID
        data.title = title
        data.subTitle = subTitle
        data.footer = footer
        data.sort = sort
        return data
    }

    func copyID() -> SubCategoryRealmData {
        let data = SubCategoryRealmData()
        data.id = UUID().uuidString
        data.categoryID = categoryID
        data.title = title
        data.subTitle = subTitle
        data.footer = footer
        data.sort = sort
        return data
    }
}

class ItemRealmData: Object, ObjectKeyIdentifiable, Codable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var categoryID: String = ""
    @Persisted var subcategoryID: String = ""
    @Persisted var title: String = .init(localized: "新项目")
    @Persisted var subTitle: String = .init(localized: "NewItem")
    @Persisted var header: String = ""
    @Persisted var prices = List<PriceRealmData>()
    @Persisted var sort: Int = 0


    func copyID() -> ItemRealmData {
        let data = ItemRealmData()
        data.id = UUID().uuidString
        data.categoryID = categoryID
        data.subcategoryID = subcategoryID
        data.title = title
        data.subTitle = subTitle
        data.header = header
        data.sort = sort

        // 深拷贝 prices 列表
        let newPrices = List<PriceRealmData>()
        for p in prices {
            newPrices.append(p.copyID())
        }
        data.prices = newPrices

        return data
    }

    static func create(
        id _: String = UUID().uuidString,
        categoryID: String = "",
        subcategoryID: String = "",
        title: String = String(localized: "新项目"),
        subTitle: String = String(localized: "NewItem"),
        header: String = "",
        prices: [PriceRealmData] = [],
        sort: Int = 0
    ) -> ItemRealmData {
        let data = ItemRealmData()
        data.id = UUID().uuidString
        data.categoryID = categoryID
        data.subcategoryID = subcategoryID
        data.title = title
        data.subTitle = subTitle
        data.header = header
        let results = List<PriceRealmData>()
        for item in prices {
            results.append(item)
        }
        data.prices = results
        data.sort = sort
        return data
    }

    func show(_ modes: PriceTypeEnum...) -> Bool {
        prices.contains { modes.contains($0.mode) }
    }
}

class PriceRealmData: Object, ObjectKeyIdentifiable, Codable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var prefix: String = "¥"
    @Persisted var money: Int = 0
    @Persisted var suffix: String = "元/次"
    @Persisted var discount: Bool = false
    @Persisted var mode = PriceTypeEnum.A

    func copyID() -> PriceRealmData {
        let data = PriceRealmData()
        data.prefix = prefix
        data.money = money
        data.suffix = suffix
        data.discount = discount
        data.mode = mode
        return data
    }

    static func create(
        id: String = UUID().uuidString,
        prefix: String = "¥",
        money: Int = 0,
        suffix: String = "元/次",
        discount: Bool = false,
        mode: PriceTypeEnum = PriceTypeEnum.A
    ) -> PriceRealmData {
        let data = PriceRealmData()
        data.id = id
        data.prefix = prefix
        data.money = money
        data.suffix = suffix
        data.discount = discount
        data.mode = mode
        return data
    }

    static func space(_ number: String = "") -> PriceRealmData {
        let price = PriceRealmData()
        price.prefix = "¥"
        price.money = 0
        price.suffix = String(localized: "元/\(number)次")
        price.discount = false
        return price
    }
}

enum PriceTypeEnum: String, PersistableEnum, CaseIterable, Codable {
    case A
    case B
    case C
    case D
}

struct TotalRealmData: Codable, @unchecked Sendable {
    var Cards: [MemberCardRealmData]
    var Categorys: [CategoryRealmData]
    var Subcategorys: [SubCategoryRealmData]
    var Items: [ItemRealmData]
    var menusName: String?
    var menusSubName: String?
    var menusFooter: String?
    var menusImage: String?
    var homeCardTitle: String?
    var homeCardSubTitle: String?
    var homeItemsTitle: String?
    var homeItemsSubTitle: String?
    var settingPassword: String?
    var remoteUpdateURL: String?
    var searchApi: String?
    var searchAuth: String?
}

extension TotalRealmData: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .trnExportType) {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            return try encoder.encode($0)
        }
        .suggestedFileName("PeacockMenus-\(Date().yyyyMMddhhmmss())")
    }

    enum EncryptionError: Error {
        case failed
    }
}

class VipInfoRealmMode: Object, ObjectKeyIdentifiable, Codable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var createDate: Date = .init()
    @Persisted var name: String = ""
    @Persisted var cardLevel: String = ""
    @Persisted var balance: Int = 0
    @Persisted var cardID: String = ""
    @Persisted var cardType: String = ""
    @Persisted var phone: String = ""
    @Persisted var isGift: Bool = false
    @Persisted var year: Int = 0

    static func create(
        createDate: Date = Date(),
        name: String = "",
        cardLevel: String = "",
        balance: Int = 0,
        cardID: String = "",
        cardType: String = "",
        phone: String = "",
        isGift: Bool = false
    ) -> VipInfoRealmMode {
        let data = VipInfoRealmMode()
        data.id = UUID().uuidString
        data.name = name
        data.cardLevel = cardLevel
        data.balance = balance
        data.cardID = cardID
        data.cardType = cardType
        data.phone = phone
        data.createDate = createDate
        data.isGift = isGift
        data.year = Calendar.current.component(.year, from: createDate)
        return data
    }

    static func YEAR() -> Int {
        Calendar.current.component(.year, from: Date())
    }

    static func create(vipinfo: VipInfo) -> VipInfoRealmMode {
        let data = VipInfoRealmMode()
        data.id = UUID().uuidString
        data.name = vipinfo.name
        data.cardLevel = vipinfo.cardLevel
        data.balance = vipinfo.balance
        data.cardID = vipinfo.cardID
        data.cardType = vipinfo.cardType
        data.phone = vipinfo.phone
        data.createDate = vipinfo.date ?? Date()
        data.isGift = vipinfo.isGift
        data.year = Calendar.current.component(.year, from: data.createDate)
        return data
    }
}


class MenusHomeInfo:  Object, ObjectKeyIdentifiable, Codable {
    
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var menusName = String(localized: "美丽宫略") 
    @Persisted var menusSubName = String(localized: "Peacock-Menus")
    @Persisted var menusFooter = String(localized: "一次相遇，终身美好")
    @Persisted var menusImage = String(localized: "other")
    @Persisted var homeCardTitle = String(localized: "会员卡")
    @Persisted var homeCardSubTitle = String(localized: "Peacock-Cards")
    @Persisted var homeItemsTitle = String(localized: "项目分类")
    @Persisted var homeItemsSubTitle = String(localized: "Peacock-Items")
    
}
