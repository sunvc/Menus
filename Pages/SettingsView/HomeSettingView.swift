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
    @EnvironmentObject var manager: peacock
    @Default(.settingPassword) var settingPassword
    @Default(.defaultHome) var defaultHome
    @FocusState var isFocused: Bool

    @State private var showAlert: Bool = false

    @State private var isTryingAgain: Bool = false

    @State private var password: String = ""

    var isAuth: Bool {
        settingPassword.count > 1 && !password.auth(password: settingPassword)
    }

    var body: some View {
        ZStack {
            if ISPAD {
                SettingsView()
            } else {
                SettingsIphoneView()
            }
        }
        .onChange(of: defaultHome) {
            self.password = ""
        }
    }
}

#Preview {
    HomeSettingView()
        .environmentObject(peacock.shared)
}
