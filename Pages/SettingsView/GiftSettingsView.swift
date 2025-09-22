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
						Text(createDate(value))
						
					}
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
				Text("\(gifts.keys.count)")
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
