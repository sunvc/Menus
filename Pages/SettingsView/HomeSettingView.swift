//
//  HomeSettingView.swift
//  PeacockMenus
//
//  Created by He Cho on 2024/9/22.
//

import SwiftUI
import Defaults
import TipKit

struct HomeSettingView: View {
	@EnvironmentObject var manager:peacock
	@Default(.settingPassword) var settingPassword
    @Default(.defaultHome) var  defaultHome
	@FocusState var isFocused:Bool
	
	@State private var showAlert:Bool = false
	
	@State private var isTryingAgain: Bool = false
	
    @State private var password:String = ""
    
    var isAuth:Bool{
        settingPassword.count > 1 &&  password != settingPassword
    }
	var body: some View {
        ZStack{
            if ISPAD{
                SettingsView()
            }else{
                SettingsIphoneView()
            }
        }
		.alert(isPresented: $showAlert) {
			Alert(title: Text("恢复初始化"), message: Text("初始化将删除全部数据"), primaryButton: .destructive(Text("确定"), action: {
				Defaults.reset(.Cards,.Categorys,.Subcategorys,.Items, .settingPassword)
			}), secondaryButton: .cancel())
		}
        .overlay{
            if isAuth && defaultHome == .home{
                
                ZStack{
                    
                    Rectangle()
                        .fill(.ultraThinMaterial)
                    
                    CustomAlertWithTextField(password: $password) {
                        withAnimation {
                            self.password = ""
                            manager.page = defaultHome
                        }
                    }
                    .ignoresSafeArea()
                }
                
            }
           
        }
        .onChange(of: defaultHome) {
            self.password = "`"
        }
		
		
		
	}
	
}

#Preview {
	HomeSettingView()
		.environmentObject(peacock.shared)
}
