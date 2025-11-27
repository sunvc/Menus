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
}

struct GiftHomeView: View {
    @State private var searchText: String = ""
    @FocusState private var phoneFocus
    @State private var viplist: [VipInfo] = []
    @Default(.defaultHome) var defaultHome
    @State private var showGifts = false

    @State private var searchLoading: Bool = false

    @ObservedResults(
        VipInfoRealmMode.self,
        sortDescriptor: SortDescriptor(
            keyPath: \VipInfoRealmMode.createDate,
            ascending: false
        )
    ) var vipGiftlist

    var background: Color {
        let diskBool = vipGiftlist.contains(where: { $0.phone == searchText })

        let lingCount = viplist.filter { item in
            vipGiftlist.contains(where: { $0.phone == item.phone })
        }.count
        if diskBool {
            return lingCount == viplist.count ? .red : .yellow
        } else {
            switch lingCount {
            case 0:
                return .green
            case viplist.count:
                return .red
            default:
                return .yellow
            }
        }
    }

    var titlegift: String {
        let diskBool = vipGiftlist.where { $0.phone == searchText }.count > 0

        let lingCount = viplist.filter { item in
            vipGiftlist.where { $0.phone == item.phone }.count > 0
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
            Text(titlegift)
                .font(.system(size: 600).bold())
                .minimumScaleFactor(0.5)

            VStack {
                Spacer()
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(viplist, id: \.id) { item in
                            VipListView(item: item)
                                .padding()
                                .contentShape(RoundedRectangle(cornerRadius: 10))
                                .shadow(color: .white.opacity(0.8), radius: 2, x: -1, y: -1)
                                .shadow(color: .black, radius: 10, x: 10, y: 10)
                        }
                    }
                }

                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2)
            }

            VStack(alignment: .leading) {
                HStack {
                    Text("查询结果:")
                        .foregroundStyle(.gray)
                    Text(viplist.count == 0 ? "没有结果" : "查询到\(viplist.count)个结果")
                        .foregroundStyle(.white)
                }
                .padding(.horizontal)

                HStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .frame(width: 600, height: 100)
                        .overlay {
                            TextField("输入手机号码搜索", text: $searchText)
                                .font(.largeTitle)
                                .padding(.leading, 80)
                                .focused($phoneFocus)
                                .submitLabel(.search)
                                .onSubmit {
                                    withAnimation {
                                        self.getVipList(search: searchText)
                                        self.phoneFocus = false
                                    }
                                }
                        }
                        .overlay {
                            HStack {
                                Image(systemName: "phone")
                                    .font(.largeTitle)
                                    .padding(.horizontal)

                                Spacer()
                                if searchText.count > 0 {
                                    Image(systemName: "xmark")
                                        .padding(10)
                                        .background(.ultraThinMaterial)
                                        .clipShape(Circle())
                                        .font(.largeTitle)
                                        .padding(.trailing)
                                        .onTapGesture {
                                            withAnimation {
                                                self.searchText = ""
                                                self.viplist = []
                                            }
                                        }
                                }
                            }
                        }
                        .contentShape(RoundedRectangle(cornerRadius: 20))
                }
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
        .background(background)
        .sheet(isPresented: $showGiftList) {
            NavigationStack {
                List {
                    ForEach(vipGiftlist, id: \.id) { value in
                        HStack {
                            Text(value.phone)
                            Spacer()
                            Text(value.name)

                            Text(verbatim: "-")

                            Text(value.cardLevel)
                            Spacer()
                            Text(createDate(value.createDate))
                        }
                        .minimumScaleFactor(0.5)
                        .padding(.horizontal, 10)
                        .font(.title2)
                    }
                }
                .navigationTitle("领取列表")
                .toolbar {
                    if vipGiftlist.count > 0 {
                        ToolbarItem {
                            Text("\(vipGiftlist.count)")
                                .padding(.horizontal)
                                .contentShape(Rectangle())
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    func VipListView(item: VipInfo) -> some View {
        let success = vipGiftlist
            .filter { $0.phone == item.phone && $0.year == VipInfoRealmMode.YEAR()
            }.count > 0
        VStack {
            Button {
                if !success {
                    $vipGiftlist.append(
                        VipInfoRealmMode
                            .create(
                                name: item.name,
                                cardLevel: item.cardLevel,
                                balance: item.balance,
                                cardID: item.cardID,
                                cardType: item.cardType,
                                phone: item.phone,
                                isGift: item.isGift
                            )
                    )
                }

            } label: {
                HStack {
                    Spacer()

                    Text(
                        success ? "已领:\(createDate(item.date))" : "点击领取"
                    )
                    .padding()
                    .font(success ? .system(size: 30) : .system(size: 50).bold())
                    Spacer()
                }
            }
            .background(success ? .red : .accent)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .disabled(success)

            HStack {
                Text(item.cardLevel)
                    .font(.system(size: 50).bold())
                    .foregroundStyle(.black)

                Spacer()

                Text(item.phone)
                    .font(.title)
                    .foregroundStyle(.black)

            }.padding()
            Divider()

            HStack {
                Text("会员姓名:")
                    .font(.title)
                    .foregroundStyle(.gray)
                Spacer()
                Text(item.name)
                    .font(.largeTitle)
            }.padding()

            Divider()
            HStack {
                Spacer()
                Text(item.cardID)
                    .font(.title)

            }.padding(.leading, 50)
                .overlay {
                    HStack {
                        Text("卡号:")
                            .font(.title)
                            .foregroundStyle(.gray)
                        Spacer()
                    }
                }
                .padding()

            Spacer()
        }
        .frame(width: 500)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .scaleEffect(0.85)
        .clipped()
    }

    func getVipList(search: String) {
        let searchApi = Defaults[.searchApi]
        let searchAuth = Defaults[.searchAuth]
        searchLoading = true

        AF.request(
            searchApi,
            method: .get,
            parameters: ["text": search, "page": 1],
            headers: ["Authorization": searchAuth]
        ).response { response in
            switch response.result {
            case .success(let result):
                if let result = result, let json = try? JSON(data: result) {
                    self.viplist = dataHandler(data: json)
                }

            case .failure(let err):
                debugPrint(err.localizedDescription)
            }

            self.searchLoading = false
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

#Preview {
    GiftHomeView()
        .ignoresSafeArea()
}
