//
//  BasicSettingsView.swift
//  PeacockMenus
//
//  Created by He Cho on 2024/9/16.
//

import SwiftUI
import Defaults
import Assistant

struct BasicSettingsView: View {
    
    @State private var selectedTab:Int? = 0
    @Binding var columnVisibility: NavigationSplitViewVisibility
    @State private var showAlert:Bool = false
    @State private var showIconPicker:Bool = false
    @Default(.defaultHome) var defaultHome
    @Default(.results) var results
    
    let initTip = InitializeDataView()
    
    var body: some View {
        NavigationStack{
            List(selection: $selectedTab){
                
                Section{
                    Picker(selection: $defaultHome, label: Text("默认首页")) {
                        ForEach(Page.arr, id: \.self){ icon in
                            Label(icon.name, systemImage: icon.rawValue)
                        }
                    }
                    
                }header: {
                    Label("切换默认首页", systemImage: "house.circle")
                }
                
                Section{
                    NavigationLink{
                        AppSettings()
                            .navigationTitle("App设置")
                    }label: {
                        Label("App设置", systemImage: "house.circle")
                    }
                    
                    .tag(1)
                    
                    
                    NavigationLink{
                        CalculatorSettings()
                    }label:{
                        Label("计算器设置", systemImage: "house.circle")
                    }
                    
                    NavigationLink{
                        AssistantSettingsView()
                    }label:{
                        Label("智能助手", systemImage: "gear")
                    }
                    
                    if defaultHome == .home{
                        NavigationLink{
                            ExportDataView()
                                .navigationTitle("导出信息")
                        }label: {
                            Label("导出信息", systemImage: "square.and.arrow.up")
                        }
                        
                        .tag(2)
                        
                        NavigationLink{
                            ImportDataView()
                                .navigationTitle("导入信息")
                        }label: {
                            Label("导入信息", systemImage: "square.and.arrow.down")
                        }
                        
                    }
                   
                    
                    Button{
                        self.showIconPicker.toggle()
                    }label:{
                        
                        Label("切换图标", systemImage: "photo.circle")
                    }
                    .sheet(isPresented: $showIconPicker) {
                        NavigationStack{
                            AppIconView()
                        }.presentationDetents([.medium])
                    }
                    
                    NavigationLink{
                        NavigationStack{
                            GiftSettingsView()
                                .navigationTitle("礼物领取设置")
                        }
                    }label: {
                        Label("礼物领取", systemImage: "app.gift.fill")
                    }
                }header:{
                    Text(verbatim: "")
                }
                
                
               
                
                
                
            }.navigationTitle("通用设置")
                .onChange(of: selectedTab) { _, _ in
                    self.columnVisibility = .doubleColumn
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("恢复初始化"), message: Text("是否确定恢复初始化"), primaryButton: .destructive(Text("确定"), action: {
                        Defaults.reset(.Cards,.Categorys,.Subcategorys,.Items, .settingPassword)
                    }), secondaryButton: .cancel())
                }
                .toolbar{
                    if defaultHome != .home{
                        ToolbarItem {
                            Button{
                                withAnimation {
                                    peacock.shared.page = defaultHome
                                }
                            }label: {
                                Image(systemName: "xmark")
                            }
                        }
                    }
                    
                    ToolbarItem {
                        Button{
                            if InitializeDataView.startTipHasDisplayed{
                                showAlert.toggle()
                            }
                            InitializeDataView.startTipHasDisplayed = true
                            
                        }label: {
                            Image(systemName: "gearshape.arrow.triangle.2.circlepath")
                                .popoverTip(initTip)
                            
                            
                        }
                        
                    }
                    
                    
                }
            
        }
    }
}

#Preview {
    BasicSettingsView(columnVisibility:.constant(.doubleColumn))
}
