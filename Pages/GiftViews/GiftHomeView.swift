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
	static let gifts = Key<[String:Date]>("gist",default: [:])
}

struct GiftHomeView:View {
	@State private var phone:String = ""
	@FocusState private var phoneFocus
	@State private var viplist:[VipList] = []
	@Default(.gifts) var gifts
	
	
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
						.foregroundStyle(.white)
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
						withAnimation {
							self.getVipList(search: phone)
							self.phoneFocus = false
						}
						
					}label: {
						Image(systemName: "mail.and.text.magnifyingglass")
							.resizable()
							.frame(width: 50, height: 50)
					}
				}
			}.offset(y: -130)
			
		}
		.ignoresSafeArea()
		.background(background)
		
	}
	
	
	@ViewBuilder
	func cardGiftView(item:VipList)-> some View{
		VStack{
			
			Button{
				gifts[item.phone] = Date()
				debugPrint(gifts)
			}label: {
				HStack{
					Spacer()
					Text( gifts.contains(where: {$0.key == phone}) ? (item.date ?? "已领取") : "领取")
						.padding()
						.font( gifts.contains(where: {$0.key == phone}) ? .system(size: 30)  : .system(size: 50).bold())
						
						
					Spacer()
				}
				
				.clipShape(RoundedRectangle(cornerRadius: 10))
				Spacer()
			}
			.buttonStyle(BorderedProminentButtonStyle())
			.disabled(gifts.contains(where: {$0.key == item.phone}))
			
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
		
		
		let url = "https://shkqg.com/rabbit/miniapp/v2/api/searchVip"
		AF.request(url, method: .get, parameters: ["text": search,"page":1], headers: ["Authorization": "otO9Z5I-iCGMUumXN2t7m3lYI-OE"]).response{ response in
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
	
	func dataHandler(data:JSON) -> [VipList]{
//		debugPrint(data["data"]["data"])
		
		let vipList = data["data"]["data"]
		
		var result:[VipList] = []
		
		for (_,item) in vipList{
			let balance = item["info"]["balance"].rawValue as? Int ?? 0
			let cardLevel = item["cardLevel"].rawValue as? String ?? ""
			let name = item["name"].rawValue as? String ?? ""
			let cardID = item["card"].rawValue as? String ?? ""
			let cardType =  item["cardType"].rawValue as? String ?? ""
			let phone = item["phone"].rawValue as? String ?? ""
			debugPrint(item)
			if (cardType == "4"  || cardType == "8" || cardType == "11") && phone != "" {
				result.append(VipList(name: name, cardLevel: cardLevel, balance: balance, cardID: cardID,cardType: cardType,phone: phone, date: createDate(gifts[phone])))
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


struct VipList:Codable, Defaults.Serializable{
	var id:String = UUID().uuidString
	var name:String
	var cardLevel:String
	var balance:Int
	var cardID:String
	var cardType:String
	var phone:String
	var date:String?
	var isGift:Bool = false
}


#Preview {
	GiftHomeView()
		.ignoresSafeArea()
}


