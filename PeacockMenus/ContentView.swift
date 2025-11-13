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
    @Default(.remoteUpdateUrl) var remoteUpdateUrl
    @Default(.showMenus) var showMenus

	var body: some View {
		
        ZStack(alignment: .top){
            Group{
                switch manager.page{
                case .home:
                    MenuPriceView()
                case .setting:
                    HomeSettingView()
                case .deepseek:
                    AssistantPage()
                case .calculator:
                    NavigationStack{
                        CalculatorView()
                    }
                case .gift:
                    NavigationStack{
                        GiftHomeView()
                    }
                }
                
            }
			.transition(AnyTransition.opacity.combined(with: .slide))
			
			
		}
        .fullScreenCover(isPresented: $manager.fullPage) {
            ScanView{ code in
                if let url = URL(string: code), (url.scheme == "http" || url.scheme == "https") {
                    manager.updateItem(url: code) { success in
                        if success{
                            DispatchQueue.main.async {
                                Defaults[.remoteUpdateUrl] = code
                                Defaults[.defaultHome] = .home
                                Defaults[.showMenus] = true
                                manager.page = .home
                            }
                            
                        }else{
                            DispatchQueue.main.async {
                                Defaults.Keys.resetApp()
                                manager.page = .deepseek
                                manager.toast("Restore App Success !!!")
                            }
                        }
                    }
                    
                    
                }
                return true
            }
        }
    }
    
    @ViewBuilder
    func AssistantPage() -> some View{
        NavigationStack{
            AssistantView {
                Section{
                    ForEach(Page.arr, id: \.self) { item in

                        if item != .deepseek {
                            if item != .home{
                                Button{
                                    withAnimation{
                                        manager.page = item
                                    }
                                }label:{
                                    Label(item.name, systemImage: item.rawValue)
                                }
                            }else{
                                if showMenus{
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

            }logoBtn: {
                self.showMenus.toggle()
                if showMenus{
                    manager.toast("Unlock A Surprise!")
                }else{
                    manager.toast("Close")
                }

            } close: {
                manager.page = defaultHome
            }
            .toolbar{
                ToolbarItem(placement: .topBarLeading) {
                    Button{
                        manager.fullPage = true
                    }label:{
                        Image(systemName: "qrcode.viewfinder")
                    }
                }
            }


        }
    }
	
}

#Preview {
	ContentView()
		.environmentObject(peacock.shared)
}

