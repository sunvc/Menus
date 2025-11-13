//
//  GiftSettingsView.swift
//  PeacockMenus
//
//  Created by He Cho on 2024/10/25.
//

import SwiftUI
import Defaults

struct GiftSettingsView:View {
	@Default(.giftsNew) var giftsNew
    @Default(.searchApi) var searchApi
    @Default(.searchAuth) var searchAuth
    @Default(.giftShow) var giftShow
    @State private var showDelete = false
    var results:String{
        var results:String = ""
        var index:Int = 0
        for (key, value) in giftsNew{
            index += 1
            let line:String = "\(index),\(key),\(value.name),\(value.cardLevel),\(value.date.yymm)\n"
            results.append(line)
        }
        return results
    }
    
    var datas:[VipInfo]{
        giftsNew.values.sorted(by: {$0.date ?? Date() > $1.date ?? Date()}).map({$0})
    }
    @FocusState private var searchFocus
    @FocusState private var searchPassword
	var body: some View {
		VStack{
			
			List{
				
                Section {
                    Defaults.Toggle("礼物领取开关", systemImage: "app.gift.fill",key: .giftShow)
                        .onChange(of: giftShow) { oldValue, newValue in
                            if newValue && !searchApi.hasPrefix("http") {
                                self.giftShow = false
                            }
                        }
                    
                    if !giftShow{
                        TextField("API", text: $searchApi)
                            .focused($searchFocus)
                            .customField(focus: searchFocus, icon: "link",data:  $searchApi)
                        
                        SecureField("key", text: $searchAuth)
                            .focused($searchPassword)
                            .customField(focus: searchPassword,icon: "key",data:  $searchAuth)
                    }
                    
                }
                

                ForEach(datas, id: \.id){ value in

                    HStack{
                        Text(value.phone)
                        Spacer()
                        Text(value.name)

                        Text(verbatim: "-")
                        
                        Text(value.cardLevel)
                        Spacer()
                        Text(value.date.yymm)
                    }
                    .minimumScaleFactor(0.5)
                    .padding()
                    .font(.title2)
                    .swipeActions(allowsFullSwipe: true) {
                        Button{
                            giftsNew.removeValue(forKey: value.phone)
                        }label: {
                            Text("删除")
                        }.tint(.red)
                    }

                }
            }
        }
        .toolbar {
            if giftsNew.keys.count > 0{
                ToolbarItem {
                    
                    Text("\(giftsNew.keys.count)")
                        .padding(.horizontal)
                        .contentShape(Rectangle())
                        .onTapGesture(count: showDelete ? 1 : 5) {
                            self.showDelete.toggle()
                        }
                }
            }

            if !results.isEmpty{
                ToolbarItem(placement: .topBarLeading) {
                    ShareLink(item: results)
                }
            }

            if showDelete && !giftsNew.isEmpty{
                ToolbarItem(placement: .topBarLeading) {
                    Button{
                        self.giftsNew = [:]
                    }label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
	}
	
	
}

extension Date?{
    var yymm: String {
        guard let self else { return  ""}
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: self)
    }
}
