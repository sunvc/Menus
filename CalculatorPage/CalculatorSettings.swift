//
//  SidebarMenu.swift
//  Calculator
//
//  Created by lynn on 2025/6/30.
//

import SwiftUI
import Defaults

struct CalculatorSettings: View {
    
    @Default(.results) var results
    @Default(.thousandPoints) var thousandPoints
    @Default(.numberSuffix) var numberSuffix
    @Default(.doubleInt) var doubleInt
    @Default(.feedback) var feedback
    @Default(.defaultHome) var defaultHome
    var body: some View {
        NavigationStack{
            List{
                
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
                    Toggle(isOn: $thousandPoints) {
                        Label("千分位", systemImage: "gear")
                    }
                    Toggle(isOn: $numberSuffix) {
                        Label("单位", systemImage: "gear")
                    }
                    Picker(selection: $doubleInt, label: Text("小数")) {
                        ForEach(Array(0...8),id: \.self) { item in
                            Text("\(item)").tag(item)
                        }
                        
                    }
                }header: {
                    Text(verbatim: "")
                }
                Section{
                    Toggle(isOn: $feedback) {
                        Label("触感", systemImage: "gear")
                    }
                    
                }header: {
                    Text(verbatim: "")
                }
                
                Section{
                    
                    ZStack{
                        Color.orange
                        HStack{
                            Spacer()
                            Text("清空屏幕")
                            Spacer()
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .listRowBackground(Color.clear)
                    .VButton( onRelease: { _ in
                        self.results = []
                        return true
                    })
                    
                    
                }header: {
                    Text(verbatim: "")
                }
            }
            .navigationTitle("计算器")
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
}


#Preview {
   ContentView()
}
