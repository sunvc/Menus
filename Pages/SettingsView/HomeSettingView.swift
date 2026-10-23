//
//  HomeSettingView.swift
//  PeacockMenus
//
//  Created by He Cho on 2024/9/22.
//

import Defaults
import SwiftUI
import TipKit

struct HomeSettingView: View {
    
    @Environment(\.horizontalSizeClass) var sizeClass

    var body: some View {
        ZStack {
            if sizeClass == .regular{
                SettingsView()
            } else {
                SettingsIphoneView()
            }
        }
        
        .scrollDismissesKeyboard(.interactively)
    }
}

#Preview {
    HomeSettingView()
        
}
