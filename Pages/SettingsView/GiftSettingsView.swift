//
//  GiftSettingsView.swift
//  PeacockMenus
//
//  Created by He Cho on 2024/10/25.
//

import SwiftUI
import Defaults

struct GiftSettingsView:View {
	@Default(.gifts) var gifts
    @Default(.searchApi) var searchApi
    @Default(.searchAuth) var searchAuth
    @Default(.giftShow) var giftShow
    @State private var showDelete = false
    var datas:String{
        var results:String = ""
        var index:Int = 0
        for (key, value) in gifts{
            index += 1
            let line:String = "\(index),\(key),\(value.name),\(value.cardLevel),\(createDate(value.date))\n"
            results.append(line)
        }
        return results
    }
	var body: some View {
		VStack{
			
			List{
				
                Section {
                    Defaults.Toggle("礼物领取开关", systemImage: "app.gift.fill",key: .giftShow)
                    if giftShow{
                        TextField("API", text: $searchApi)
                            .customField(icon: "link",data:  $searchApi)
                        
                        SecureField("key", text: $searchAuth)
                            .customField(icon: "key",data:  $searchAuth)
                    }
                    
                }
                

                ForEach(gifts.sorted(by: { $0.key < $1.key }), id: \.key){key, value in

                    HStack{
                        Text(key)
                        Spacer()
                        Text(value.name)

                        Text(verbatim: "-")
                        
                        Text(value.cardLevel)
                        Spacer()
                        Text(createDate(value.date))
                    }
                    .minimumScaleFactor(0.5)
                    .padding()
                    .font(.title2)
                    .swipeActions(allowsFullSwipe: true) {
                        Button{
                            gifts.removeValue(forKey: key)
                        }label: {
                            Text("删除")
                        }.tint(.red)
                    }

                }
            }
        }.toolbar {
            ToolbarItem {
                Button{
                    self.showDelete.toggle()
                }label: {
                    Text("\(gifts.keys.count)")
                }
            }

            if !datas.isEmpty{
                ToolbarItem(placement: .topBarLeading) {
                    ShareLink(item: datas)
                }


            }

            if showDelete && !gifts.isEmpty{
                ToolbarItem(placement: .topBarLeading) {
                    Button{
                        self.gifts = [:]
                    }label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
	}
	
	func createDate(_ date:Date?) -> String{
		guard let date else { return  ""}
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd HH:mm"
		return formatter.string(from: date)
	}
	
}
