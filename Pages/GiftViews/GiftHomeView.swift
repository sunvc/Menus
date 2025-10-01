//
//  GiftHomeView.swift
//  PeacockMenus
//
//  Created by He Cho on 2024/10/24.
//


import SwiftUI
import Alamofire
import SwiftyJSON
import Defaults



extension Defaults.Keys{
    static let gifts = Key<[String: VipInfo]>("gist",default: [:])
}

struct GiftHomeView:View {
	@State private var phone:String = ""
	@FocusState private var phoneFocus
	@State private var viplist:[VipInfo] = []
	@Default(.gifts) var gifts
    @Default(.defaultHome) var defaultHome
	
	var background:Color{
		
		let diskBool = gifts.contains(where: {$0.key == phone})
		
		let lingCount = viplist.filter({ item in
			gifts.contains(where: {$0.key == item.phone})
		}).count
		if diskBool{
			return lingCount == viplist.count ? .red : .yellow
		}else{
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
	
	var titlegift:String{
	
		
		let diskBool = gifts.contains(where: {$0.key == phone})
		
		let lingCount = viplist.filter({ item in
			gifts.contains(where: {$0.key == item.phone})
		}).count
		if diskBool{
			return lingCount == viplist.count ? "已领" : "部分"
		}else{
			
			if viplist.count == 0{
				return "礼品领取"
			}else{
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
	
	var body: some View {
		ZStack{
			
			Text(titlegift)
				.font(.system(size: 600).bold())
				.minimumScaleFactor(0.5)
			
			VStack{
				
				Spacer()
				ScrollView(.horizontal) {
					LazyHStack{
						ForEach(viplist, id: \.id){item in
							cardGiftView(item: item)
								.padding()
						}
					}
				}
				
				.frame(width: UIScreen.main.bounds.width,height: UIScreen.main.bounds.height / 2)
			}
			
			VStack(alignment: .leading){
				HStack{
					Text("查询结果:")
						.foregroundStyle(.gray)
					Text( viplist.count == 0 ? "没有结果" : "查询到\(viplist.count)个结果")
                        .foregroundStyle(.black)
				}
				.padding(.horizontal)
				
				HStack{
					RoundedRectangle(cornerRadius: 20)
						.fill(.ultraThinMaterial)
						.frame(width: 600, height: 100)
						.onTapGesture {
							self.phoneFocus.toggle()
						}
						
						.overlay {
							TextField("输入手机号码搜索", text: $phone)
								.font(.largeTitle)
								.padding(.leading, 80)
								.focused($phoneFocus)
						}
						.overlay {
							HStack{
								Image(systemName: "phone")
									.font(.largeTitle)
									.padding(.horizontal)
								
								Spacer()
								
								Image(systemName: "xmark")
									.background(.ultraThinMaterial)
									.font(.largeTitle)
									.padding(.trailing)
									.onTapGesture {
										withAnimation {
											self.phone = ""
											self.viplist = []
										}
									}
									.opacity(phone.count > 0 ? 1 : 0)
							}
						}
						.contentShape(RoundedRectangle(cornerRadius: 20))
					
					
					Button{
                        if !phone.isEmpty{
                            withAnimation {
                                self.getVipList(search: phone)
                                self.phoneFocus = false
                            }
                        }

						
					}label: {
						Image(systemName: "person.crop.badge.magnifyingglass")
                            .font(.largeTitle)
                            .padding(10)
                            .background(.ultraThinMaterial, in: .circle)
                            .scaleEffect(1.5)
                            .tint(.background9)
                            .offset(x: 20)
					}
				}
			}.offset(y: -130)
			
		}
        .overlay(alignment: .topTrailing, content: {
            Button{
                withAnimation {
                    peacock.shared.page = defaultHome
                }
            }label:{
                Image(systemName: "xmark")
                    .font(.title)
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .padding()
                    .offset(y: 10)
            }
        })
		.ignoresSafeArea()
		.background(background)

		
	}
	
	
	@ViewBuilder
	func cardGiftView(item:VipInfo)-> some View{
		VStack{
			
			Button{
                if !gifts.contains(where: {$0.key == item.phone}){
                    var userInfo = item
                    userInfo.date = Date()
                    gifts[item.phone] = userInfo
                }

			}label: {
				HStack{
					Spacer()
                    Text(
                        gifts
                            .contains(where: {$0.key == phone}) ? (
                                createDate(item.date) ?? "已领取"
                            ) : "领取"
                    )
						.padding()
						.font( gifts.contains(where: {$0.key == phone}) ? .system(size: 30)  : .system(size: 50).bold())


						
					Spacer()
				}
				
				.clipShape(RoundedRectangle(cornerRadius: 10))
				Spacer()
			}

			.buttonStyle(BorderedProminentButtonStyle())
			
			HStack{
				
				Text(item.cardLevel)
					.font(.system(size: 50).bold())
					.foregroundStyle(.black)
				
				Spacer()
				
				
				Text(item.phone)
					.font(.title)
					.foregroundStyle(.black)
				
				
			}.padding()
			Divider()
			
			HStack{
				Text("会员姓名:")
					.font(.title)
					.foregroundStyle(.gray)
				Spacer()
				Text(item.name)
					.font(.largeTitle)
			}.padding()
			
			
			
			
			
			Divider()
			HStack{
				Spacer()
				Text(item.cardID)
					.font(.title)
				
				
			}.padding(.leading, 50)
				.overlay {
					HStack{
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
	
	func getVipList(search:String){
        let searchApi = Defaults[.searchApi]
        let searchAuth =  Defaults[.searchAuth]
		
		AF.request(searchApi, method: .get, parameters: ["text": search,"page":1], headers: ["Authorization": searchAuth]).response{ response in
			switch response.result{
			case .success(let result):
				if let json = try? JSON(data: result!){
					self.viplist = dataHandler(data: json)
				}
				
			case.failure(let err):
				debugPrint(err.localizedDescription)
			}
			
			
			
		}
		
	}
	
    func dataHandler(data:JSON) -> [VipInfo]{
//		debugPrint(data["data"]["data"])
		
		let vipList = data["data"]["data"]
		
		var result:[VipInfo] = []

		for (_,item) in vipList{
			let balance = item["info"]["balance"].rawValue as? Int ?? 0
			let cardLevel = item["cardLevel"].rawValue as? String ?? ""
			let name = item["name"].rawValue as? String ?? ""
			let cardID = item["card"].rawValue as? String ?? ""
			let cardType =  item["cardType"].rawValue as? String ?? ""
			let phone = item["phone"].rawValue as? String ?? ""
			debugPrint(item)
			if (cardType == "4"  || cardType == "8" || cardType == "11") && phone != "" {
                result
                    .append(
                        VipInfo(
                            name: name,
                            cardLevel: cardLevel,
                            balance: balance,
                            cardID: cardID,
                            cardType: cardType,
                            phone: phone,
                            date: gifts[phone]?.date
                        )
                    )
			}
			
			
		}
		
		return result
	}
	
	
	func createDate(_ date:Date?) -> String?{
		guard let date else { return  nil}
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd HH:mm"
		return formatter.string(from: date)
	}
	
	
	
}


struct VipInfo:Codable, Defaults.Serializable{
	var id:String = UUID().uuidString
	var name:String
	var cardLevel:String
	var balance:Int
	var cardID:String
	var cardType:String
	var phone:String
	var date:Date?
	var isGift:Bool = false
}


#Preview {
	GiftHomeView()
		.ignoresSafeArea()
}


