//
//  PeacockMenusApp.swift
//  PeacockMenus
//
//  Created by He Cho on 2024/9/2.
//

import SwiftUI
import Defaults
import TipKit

@main
struct PeacockMenusApp: App {
    
	@Default(.autoSetting) var autoSetting
	@Default(.firstStart) var firstStart
	@Default(.defaultHome) var defaultHome
	@Environment(\.scenePhase) var scenePhase
	@StateObject var manager = peacock.shared
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.onChange(of: scenePhase) { _, newvalue in
					
					switch newvalue{
                    case .active:
                        if defaultHome == .home {
                            manager.updateItem(url: autoSetting.url)
                        }
					case .background:
						if firstStart {
							firstStart = false
							SettingTipView.startTipHasDisplayed = false
						}
					default:
						break
					}
					
					
				}
				.environmentObject(manager)
				.task {
					
					DispatchQueue.main.async{
						manager.page  = defaultHome
					}
					
					try? Tips.configure([
						.displayFrequency(.immediate),
						.datastoreLocation(.applicationDefault)
					])
				
				}
                
			
			
		}
	}
	
	
}
