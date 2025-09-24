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
    @UIApplicationDelegateAdaptor private var appDelegate: CustomAppDelegate
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
                .onAppear{
                    appDelegate.app = self

                }

			
			
		}
	}
	
	
}


class CustomAppDelegate: NSObject, UIApplicationDelegate{

    var app:PeacockMenusApp?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
            // Setting the notification delegate
        UNUserNotificationCenter.current().delegate = self
        
        Task{
            await  self.registerForRemoteNotifications()
        }



        if Defaults[.id] == ""{
            Defaults[.id] = KeychainHelper.shared.getDeviceID()
        }

        debugPrint("start")

        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()

        debugPrint(token)
        Defaults[.deviceToken] = token

    }


}

extension CustomAppDelegate:UNUserNotificationCenterDelegate{
        // This function lets us do something when the user interacts with a notification
        // like log that they clicked it, or navigate to a specific screen
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        print("Got notification title: ", response.notification.request.content.title)
    }

        // This function allows us to view notifications in the app even with it in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
            // These options are the options that will be used when displaying a notification with the app in the foreground
            // for example, we will be able to display a badge on the app a banner alert will appear and we could play a sound
        return [.badge, .banner, .list, .sound]
    }


        // MARK: 注册设备以接收远程推送通知
    func registerForRemoteNotifications() async -> Bool {

        guard  let granted = try?  await  UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) else { return false}



        if granted {
                // 如果授权，注册设备接收推送通知
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        return granted
    }
}
