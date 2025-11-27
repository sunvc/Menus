//
//  Mock.swift
//  PeacockMenus
//
//  Created by He Cho on 2024/9/16.
//

//
//  Mock.swift
//  PeacockMenus
//
//  Created by He Cho on 2024/9/16.
//

import Foundation

let MemberCardDataS: [MemberCardRealmData] = [
    MemberCardRealmData.create(
        id: "A9428706-94C6-4944-BF1A-76036895818A",
        title: String(localized: "钻卡"),
        subTitle: String(localized: "Diamond Card"),
        money: 20000,
        name: String(localized: "3折"),
        discount: 0.3,
        discount2: 0.7,
        image: "peacock1",
        footer: String(localized: "1. 课程折扣7折\n2. 卡诗洗发水")
    ),

    MemberCardRealmData.create(
        id: "B9428706-94C6-4944-BF1A-76036895818B",
        title: String(localized: "金卡"),
        subTitle: String(localized: "Gold Card"),
        money: 15000,
        name: String(localized: "6折"),
        discount: 0.6,
        discount2: 0.8,
        image: "peacock2",
        footer: String(localized: "1. 课程折扣8折")
    ),

    MemberCardRealmData.create(
        id: "C9428706-94C6-4944-BF1A-76036895818C",
        title: String(localized: "银卡"),
        subTitle: String(localized: "Silver Card"),
        money: 10000,
        name: String(localized: "7折"),
        discount: 0.7,
        discount2: 0.9,
        image: "peacock3",
        footer: String(localized: "1. 课程折扣8折")
    ),

    MemberCardRealmData.create(
        id: "D9428706-94C6-4944-BF1A-76036895818D",
        title: String(localized: "普卡"),
        subTitle: String(localized: "Basic Card"),
        money: 5000,
        name: String(localized: "8折"),
        discount: 0.8,
        discount2: 1.0,
        image: "peacock6",
        footer: String(localized: "会员优先服务")
    ),

    MemberCardRealmData.create(
        id: "E9428706-94C6-4944-BF1A-76036895818E",
        title: String(localized: "普卡"),
        subTitle: String(localized: "Basic Card"),
        money: 2000,
        name: String(localized: "8折"),
        discount: 0.9,
        discount2: 1.0,
        image: "peacock6",
        footer: String(localized: "会员优先服务")
    ),
]

let CategoryDataS: [CategoryRealmData] = [
    CategoryRealmData.create(
        id: "F9428706-94C6-4944-BF1A-76036895818F",
        title: String(localized: "基础篇"),
        subTitle: String(localized: "Hair Cut Chapter"),
        image: "haircut",
        color: "background11"
    ),

    CategoryRealmData.create(
        id: "G9428706-94C6-4944-BF1A-76036895818G",
        title: String(localized: "烫发篇"),
        subTitle: String(localized: "Perming Chapter"),
        image: "hairperm",
        color: "background3"
    ),

    CategoryRealmData.create(
        id: "H9428706-94C6-4944-BF1A-76036895818H",
        title: String(localized: "染发篇"),
        subTitle: String(localized: "Hair Dyeing Chapter"),
        image: "haircolors",
        color: "background4"
    ),

    CategoryRealmData.create(
        id: "J9428706-94C6-4944-BF1A-76036895818J",
        title: String(localized: "护理篇"),
        subTitle: String(localized: "Hair Care Chapter"),
        image: "haircare",
        color: "background7"
    ),

    CategoryRealmData.create(
        id: "K9428706-94C6-4944-BF1A-76036895818K",
        title: String(localized: "头皮健康"),
        subTitle: String(localized: "Scalp Care Chapter"),
        image: "headcare",
        color: "background8"
    ),

    CategoryRealmData.create(
        id: "L9428706-94C6-4944-BF1A-76036895818L",
        title: String(localized: "美容篇"),
        subTitle: String(localized: "Beauty Chapter"),
        image: "beauty",
        color: "background9"
    ),
]

let SubCategoryDataS: [SubCategoryRealmData] = [
    SubCategoryRealmData.create(
        id: "F9428706-94C6-4944-BF1A-76036800001F",
        categoryID: "F9428706-94C6-4944-BF1A-76036895818F",
        title: String(localized: "总监"),
        subTitle: String(localized: "DIRECTORS"),
        footer: ""
    ),

    SubCategoryRealmData.create(
        id: "F9428706-94C6-4944-BF1A-76036800011F",
        categoryID: "F9428706-94C6-4944-BF1A-76036895818F",
        title: String(localized: "首席"),
        subTitle: String(localized: "DIRECTORS"),
        footer: ""
    ),

    SubCategoryRealmData.create(
        id: "F9428706-94C6-4944-BF1A-76036800002F",
        categoryID: "G9428706-94C6-4944-BF1A-76036895818G",
        title: String(localized: "菲灵"),
        subTitle: String(localized: "Perming"),
        footer: ""
    ),

    SubCategoryRealmData.create(
        id: "F9428706-94C6-4944-BF1A-76036800022F",
        categoryID: "G9428706-94C6-4944-BF1A-76036895818G",
        title: String(localized: "威娜"),
        subTitle: String(localized: "Perming"),
        footer: ""
    ),

    SubCategoryRealmData.create(
        id: "F9428706-94C6-4944-BF1A-76036800003F",
        categoryID: "H9428706-94C6-4944-BF1A-76036895818H",
        title: String(localized: "菲灵"),
        subTitle: String(localized: "Hair Dyeing"),
        footer: ""
    ),

    SubCategoryRealmData.create(
        id: "F9428706-94C6-4944-BF1A-76036800033F",
        categoryID: "H9428706-94C6-4944-BF1A-76036895818H",
        title: String(localized: "威娜"),
        subTitle: String(localized: "Hair Dyeing"),
        footer: ""
    ),

    SubCategoryRealmData.create(
        id: "F9428706-94C6-4944-BF1A-76036800004F",
        categoryID: "J9428706-94C6-4944-BF1A-76036895818J",
        title: String(localized: "菲灵"),
        subTitle: String(localized: "Hair Care"),
        footer: ""
    ),

    SubCategoryRealmData.create(
        id: "F9428706-94C6-4944-BF1A-76036800044F",
        categoryID: "J9428706-94C6-4944-BF1A-76036895818J",
        title: String(localized: "威娜"),
        subTitle: String(localized: "Hair Care"),
        footer: ""
    ),

    SubCategoryRealmData.create(
        id: "F9428706-94C6-4944-BF1A-76036800005F",
        categoryID: "K9428706-94C6-4944-BF1A-76036895818K",
        title: String(localized: "菲灵"),
        subTitle: String(localized: "Scalp Care"),
        footer: ""
    ),

    SubCategoryRealmData.create(
        id: "F9428706-94C6-4944-BF1A-76036800055F",
        categoryID: "K9428706-94C6-4944-BF1A-76036895818K",
        title: String(localized: "卡彼"),
        subTitle: String(localized: "Scalp Care"),
        footer: ""
    ),

    SubCategoryRealmData.create(
        id: "F9428706-94C6-4944-BF1A-76036800006F",
        categoryID: "L9428706-94C6-4944-BF1A-76036895818L",
        title: String(localized: "身体"),
        subTitle: String(localized: "Beauty"),
        footer: ""
    ),

    SubCategoryRealmData.create(
        id: "F9428706-94C6-4944-BF1A-76036800066F",
        categoryID: "L9428706-94C6-4944-BF1A-76036895818L",
        title: String(localized: "面部"),
        subTitle: String(localized: "Beauty"),
        footer: ""
    ),
]

let ItemDataS: [ItemRealmData] = [
    ItemRealmData.create(
        id: "F9428706-94C6-4944-BF1A-76036880001F",
        categoryID: "F9428706-94C6-4944-BF1A-76036895818F",
        subcategoryID: "F9428706-94C6-4944-BF1A-76036800001F",
        title: "剪发",
        subTitle: "Hair Cut",
        header: "",
        prices: [
            PriceRealmData.create(prefix: "¥", money: 100, suffix: "元/次", discount: true, mode: .A),
            PriceRealmData.create(
                prefix: "会员¥",
                money: 80,
                suffix: "元/次",
                discount: true,
                mode: .B
            ),
            PriceRealmData.create(
                prefix: "¥",
                money: 180,
                suffix: "元/6次",
                discount: true,
                mode: .C
            ),
            PriceRealmData.create(
                prefix: "¥",
                money: 250,
                suffix: "元/12次",
                discount: true,
                mode: .D
            ),
        ]
    ),

    ItemRealmData.create(
        id: "F9428706-94C6-4944-BF1A-76036880011F",
        categoryID: "F9428706-94C6-4944-BF1A-76036895818F",
        subcategoryID: "F9428706-94C6-4944-BF1A-76036800001F",
        title: "造型",
        subTitle: "Hair Cut",
        header: "",
        prices: [
            PriceRealmData.create(prefix: "¥", money: 100, suffix: "元/次", discount: true, mode: .A),
            PriceRealmData.create(
                prefix: "会员¥",
                money: 80,
                suffix: "元/次",
                discount: true,
                mode: .A
            ),
            PriceRealmData.create(
                prefix: "¥",
                money: 180,
                suffix: "元/6次",
                discount: true,
                mode: .C
            ),
            PriceRealmData.create(
                prefix: "¥",
                money: 250,
                suffix: "元/12次",
                discount: true,
                mode: .D
            ),
        ]

    ),

    ItemRealmData.create(
        id: "F9428706-94C6-4944-BF1A-76036881001F",
        categoryID: "F9428706-94C6-4944-BF1A-76036895818F",
        subcategoryID: "F9428706-94C6-4944-BF1A-76036800011F",
        title: "剪发",
        subTitle: "Hair Cut",
        header: "",
        prices: [
            PriceRealmData.create(prefix: "¥", money: 100, suffix: "元/次", discount: true, mode: .A),
            PriceRealmData.create(
                prefix: "会员¥",
                money: 80,
                suffix: "元/次",
                discount: true,
                mode: .B
            ),
            PriceRealmData.create(
                prefix: "¥",
                money: 180,
                suffix: "元/6次",
                discount: true,
                mode: .C
            ),
            PriceRealmData.create(
                prefix: "¥",
                money: 250,
                suffix: "元/12次",
                discount: true,
                mode: .D
            ),
        ]
    ),

    ItemRealmData.create(
        id: "F9428706-94C6-4944-BF1A-76036880111F",
        categoryID: "F9428706-94C6-4944-BF1A-76036895818F",
        subcategoryID: "F9428706-94C6-4944-BF1A-76036800011F",
        title: "造型",
        subTitle: "Hair Cut",
        header: "",
        prices: [
            PriceRealmData.create(prefix: "¥", money: 100, suffix: "元/次", discount: true, mode: .A),
            PriceRealmData.create(
                prefix: "会员¥",
                money: 80,
                suffix: "元/次",
                discount: true,
                mode: .B
            ),
            PriceRealmData.create(
                prefix: "¥",
                money: 180,
                suffix: "元/6次",
                discount: true,
                mode: .C
            ),
            PriceRealmData.create(
                prefix: "¥",
                money: 250,
                suffix: "元/12次",
                discount: true,
                mode: .D
            ),
        ]
    ),

    ItemRealmData.create(
        id: "F9428706-94C6-4944-BF1A-76036880002F",
        categoryID: "G9428706-94C6-4944-BF1A-76036895818G",
        subcategoryID: "F9428706-94C6-4944-BF1A-76036800002F",
        title: "烫发",
        subTitle: "Hair Cut",
        header: "",
        prices: [
            PriceRealmData.create(prefix: "¥", money: 100, suffix: "元/次", discount: true, mode: .A),
            PriceRealmData.create(
                prefix: "会员¥",
                money: 80,
                suffix: "元/次",
                discount: true,
                mode: .B
            ),
            PriceRealmData.create(
                prefix: "¥",
                money: 180,
                suffix: "元/6次",
                discount: true,
                mode: .C
            ),
            PriceRealmData.create(
                prefix: "¥",
                money: 250,
                suffix: "元/12次",
                discount: true,
                mode: .D
            ),
        ]
    ),

    ItemRealmData.create(
        id: "F9428706-94C6-4944-BF1A-76036880022F",
        categoryID: "G9428706-94C6-4944-BF1A-76036895818G",
        subcategoryID: "F9428706-94C6-4944-BF1A-76036800022F",
        title: "烫发",
        subTitle: "Hair Cut",
        header: "",
        prices: [
            PriceRealmData.create(prefix: "¥", money: 100, suffix: "元/次", discount: true, mode: .A),
            PriceRealmData.create(
                prefix: "会员¥",
                money: 80,
                suffix: "元/次",
                discount: true,
                mode: .B
            ),
            PriceRealmData.create(
                prefix: "¥",
                money: 180,
                suffix: "元/6次",
                discount: true,
                mode: .C
            ),
            PriceRealmData.create(
                prefix: "¥",
                money: 250,
                suffix: "元/12次",
                discount: true,
                mode: .D
            ),
        ]
    ),

    ItemRealmData.create(
        id: "F9428706-94C6-4944-BF1A-76036880003F",
        categoryID: "H9428706-94C6-4944-BF1A-76036895818H",
        subcategoryID: "F9428706-94C6-4944-BF1A-76036800003F",
        title: "染发",
        subTitle: "Hair Cut",
        header: "",
        prices: [
            PriceRealmData.create(prefix: "¥", money: 100, suffix: "元/次", discount: true, mode: .A),
            PriceRealmData.create(
                prefix: "会员¥",
                money: 80,
                suffix: "元/次",
                discount: true,
                mode: .B
            ),
            PriceRealmData.create(
                prefix: "¥",
                money: 180,
                suffix: "元/6次",
                discount: true,
                mode: .C
            ),
            PriceRealmData.create(
                prefix: "¥",
                money: 250,
                suffix: "元/12次",
                discount: true,
                mode: .D
            ),
        ]
    ),

    ItemRealmData.create(
        id: "F9428706-94C6-4944-BF1A-76036880033F",
        categoryID: "H9428706-94C6-4944-BF1A-76036895818H",
        subcategoryID: "F9428706-94C6-4944-BF1A-76036800033F",
        title: "染发",
        subTitle: "Hair Cut",
        header: "",
        prices: [
            PriceRealmData.create(prefix: "¥", money: 100, suffix: "元/次", discount: true, mode: .A),
            PriceRealmData.create(
                prefix: "会员¥",
                money: 80,
                suffix: "元/次",
                discount: true,
                mode: .B
            ),
            PriceRealmData.create(
                prefix: "¥",
                money: 180,
                suffix: "元/6次",
                discount: true,
                mode: .C
            ),
            PriceRealmData.create(
                prefix: "¥",
                money: 250,
                suffix: "元/12次",
                discount: true,
                mode: .D
            ),
        ]
    ),

    ItemRealmData.create(
        id: "F9428706-94C6-4944-BF1A-76036880004F",
        categoryID: "J9428706-94C6-4944-BF1A-76036895818J",
        subcategoryID: "F9428706-94C6-4944-BF1A-76036800004F",
        title: "护理",
        subTitle: "Hair Cut",
        header: "",
        prices: [
            PriceRealmData.create(prefix: "¥", money: 100, suffix: "元/次", discount: true, mode: .A),
            PriceRealmData.create(
                prefix: "会员¥",
                money: 80,
                suffix: "元/次",
                discount: true,
                mode: .B
            ),
            PriceRealmData.create(
                prefix: "¥",
                money: 180,
                suffix: "元/6次",
                discount: true,
                mode: .C
            ),
            PriceRealmData.create(
                prefix: "¥",
                money: 250,
                suffix: "元/12次",
                discount: true,
                mode: .D
            ),
        ]
    ),

    ItemRealmData.create(
        id: "F9428706-94C6-4944-BF1A-76036880044F",
        categoryID: "J9428706-94C6-4944-BF1A-76036895818J",
        subcategoryID: "F9428706-94C6-4944-BF1A-76036800044F",
        title: "护理",
        subTitle: "Hair Cut",
        header: "",
        prices: [
            PriceRealmData.create(prefix: "¥", money: 100, suffix: "元/次", discount: true, mode: .A),
            PriceRealmData.create(
                prefix: "会员¥",
                money: 80,
                suffix: "元/次",
                discount: true,
                mode: .B
            ),
            PriceRealmData.create(
                prefix: "¥",
                money: 180,
                suffix: "元/6次",
                discount: true,
                mode: .C
            ),
            PriceRealmData.create(
                prefix: "¥",
                money: 250,
                suffix: "元/12次",
                discount: true,
                mode: .D
            ),
        ]
    ),

    ItemRealmData.create(
        id: "F9428706-94C6-4944-BF1A-76036880005F",
        categoryID: "K9428706-94C6-4944-BF1A-76036895818K",
        subcategoryID: "F9428706-94C6-4944-BF1A-76036800005F",
        title: "头皮",
        subTitle: "Hair Cut",
        header: "",
        prices: [
            PriceRealmData.create(prefix: "¥", money: 100, suffix: "元/次", discount: true, mode: .A),
            PriceRealmData.create(
                prefix: "会员¥",
                money: 80,
                suffix: "元/次",
                discount: true,
                mode: .B
            ),
            PriceRealmData.create(
                prefix: "¥",
                money: 180,
                suffix: "元/6次",
                discount: true,
                mode: .C
            ),
            PriceRealmData.create(
                prefix: "¥",
                money: 250,
                suffix: "元/12次",
                discount: true,
                mode: .D
            ),
        ]
    ),

    ItemRealmData.create(
        id: "F9428706-94C6-4944-BF1A-76036880055F",
        categoryID: "K9428706-94C6-4944-BF1A-76036895818K",
        subcategoryID: "F9428706-94C6-4944-BF1A-76036800055F",
        title: "头皮",
        subTitle: "Hair Cut",
        header: "",
        prices: [
            PriceRealmData.create(prefix: "¥", money: 100, suffix: "元/次", discount: true, mode: .A),
            PriceRealmData.create(
                prefix: "会员¥",
                money: 80,
                suffix: "元/次",
                discount: true,
                mode: .B
            ),
            PriceRealmData.create(
                prefix: "¥",
                money: 180,
                suffix: "元/6次",
                discount: true,
                mode: .C
            ),
            PriceRealmData.create(
                prefix: "¥",
                money: 250,
                suffix: "元/12次",
                discount: true,
                mode: .D
            ),
        ]
    ),

    ItemRealmData.create(
        id: "F9428706-94C6-4944-BF1A-76036880006F",
        categoryID: "L9428706-94C6-4944-BF1A-76036895818L",
        subcategoryID: "F9428706-94C6-4944-BF1A-76036800006F",
        title: "美容",
        subTitle: "Hair Cut",
        header: "",
        prices: [
            PriceRealmData.create(prefix: "¥", money: 100, suffix: "元/次", discount: true, mode: .A),
            PriceRealmData.create(
                prefix: "会员¥",
                money: 80,
                suffix: "元/次",
                discount: true,
                mode: .B
            ),
            PriceRealmData.create(
                prefix: "¥",
                money: 180,
                suffix: "元/6次",
                discount: true,
                mode: .C
            ),
            PriceRealmData.create(
                prefix: "¥",
                money: 250,
                suffix: "元/12次",
                discount: true,
                mode: .D
            ),
        ]
    ),

    ItemRealmData.create(
        id: "F9428706-94C6-4944-BF1A-76036880066F",
        categoryID: "L9428706-94C6-4944-BF1A-76036895818L",
        subcategoryID: "F9428706-94C6-4944-BF1A-76036800066F",
        title: "美容",
        subTitle: "Hair Cut",
        header: "",
        prices: [
            PriceRealmData.create(prefix: "¥", money: 100, suffix: "元/次", discount: true, mode: .A),
            PriceRealmData.create(
                prefix: "会员¥",
                money: 80,
                suffix: "元/次",
                discount: true,
                mode: .B
            ),
            PriceRealmData.create(
                prefix: "¥",
                money: 180,
                suffix: "元/6次",
                discount: true,
                mode: .C
            ),
            PriceRealmData.create(
                prefix: "¥",
                money: 250,
                suffix: "元/12次",
                discount: true,
                mode: .D
            ),
        ]
    ),
]
