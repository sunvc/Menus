//
//  ContentView.swift
//  PeacockMenus
//
//  Created by He Cho on 2024/9/2.
//


import SwiftUI
import Defaults
import UIKit
import Assistant

struct ContentView: View {
	
	@EnvironmentObject var manager:peacock
	@Default(.firstStart) var firstStart
    @Default(.defaultHome) var defaultHome
    @Default(.autoSetting) var autoSetting
    
	var body: some View {
		
		ZStack(alignment: .top){
			Group{
				switch manager.page{
				case .home:
                    MenuPriceView()
				case .setting:
					HomeSettingView()
                case .deepseek:
                    NavigationStack{
                        AssistantView {
                            Section{
                                ForEach(Page.arr, id: \.self) { item in
                                    if item != .deepseek{
                                        Button{
                                            withAnimation{
                                                manager.page = item
                                            }
                                        }label:{
                                            Label(item.name, systemImage: item.rawValue)
                                        }
                                    }
                                }
                                
                            }
                        } toast: { mode, msg in
                            DispatchQueue.main.async {
                                switch mode{
                                case .error:
                                    manager.toast(msg, mode: .error)
                                case .success:
                                    manager.toast(msg, mode: .success)
                                }

                            }

                        } close: {
                            manager.page = defaultHome
                        }


                    }
                case .calculator:
                    NavigationStack{
                        CalculatorView()
                    }
				default:
					GiftHomeView()
				}
				
			}
			.transition(AnyTransition.opacity.combined(with: .slide))
        
			
			
		}
        .fullScreenCover(isPresented: $manager.fullPage) {
            ScanView{ code in
                if let url = URL(string: code), (url.scheme == "http" || url.scheme == "https") {
                    Defaults[.autoSetting] = AutoAsyncSetting(url: code, enable: true)
                    return true
                }
                return false
                
            }
        }
	}
	
}

#Preview {
	ContentView()
		.environmentObject(peacock.shared)
}

