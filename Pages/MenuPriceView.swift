//
//  MenuPriceView.swift
//  PeacockMenus
//
//  Created by He Cho on 2024/9/29.
//

import SwiftUI
import Defaults



struct MenuPriceView: View {
	
	@EnvironmentObject var manager:peacock
    @Default(.giftShow) var showGift
	var body: some View {
		NavigationStack{
            
            
            
            VStack {
                
                HomeVipCards()
                    .padding(.top, ISPAD ? 50 : 80)
                HomeItemsView()
                    .padding(.bottom, 30)
            }
            .ignoresSafeArea()
            
            
            .frame(width: windowWidth, height: windowHeight)
            .background( Color.background)
            .toolbar {
                
                
                if showGift{
                    ToolbarItem {
                        
                        Button{
                            withAnimation(.bouncy(duration: 0.3, extraBounce: 0.2)){
                                manager.page = .gift
                            }
                            
                        }label: {
                            Label("礼品领取", systemImage: "gift.fill")
                                .foregroundStyle(.pink)
                        }
                    }
                }
                ToolbarItem {
                    Button{
                        withAnimation {
                            manager.page = .calculator
                        }
                    }label:{
                        Label("计算器", systemImage: "123.rectangle")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing){
                    Button{
                        withAnimation {
                            manager.page = .deepseek
                        }
                    }label:{
                        Image(systemName: Page.deepseek.rawValue)
                    }
                   
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button{
                        withAnimation {
                            manager.page = .setting
                        }
                       
                    }label:{
                        Image(systemName: "gear")
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            
		}
       
	}
	
}

#Preview {
    ContentView()
        .environmentObject(peacock.shared)
}


extension View{
    var windowWidth:CGFloat{
        UIScreen.main.bounds.width
    }
    var windowHeight:CGFloat{
        UIScreen.main.bounds.height
    }
}
