//
//  BookTrainingApp.swift
//  BookTraining
//
//  Created by Никита Котов on 10.12.2023.
//

import SwiftUI
import UserNotifications

@main
struct BookTrainingApp: App {
    
    @Environment(\.scenePhase) var scenePhase
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    let persistenceController = PersistenceController.shared
    
    init() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor
            .black, .font: UIFont(name: "ArialRoundedMTBold", size: 35)!]
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.black, .font: UIFont(name: "ArialRoundedMTBold", size: 20)!]
        
        navBarAppearance.backgroundColor = .clear
        navBarAppearance.backgroundEffect = .none
        navBarAppearance.shadowColor = .none
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .onChange(of: scenePhase) { (phase) in
            switch phase {
                case .active: print("Active")
                case .inactive: print("Inactive")
                case .background: createQuickActions()
                @unknown default: print("Default scene phase")
            }
        }
    }
    
    func createQuickActions() {
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            let shortCutItem1 = UIApplicationShortcutItem(type: "\(bundleIdentifier).OpenFavorites", localizedTitle: "Show Favorites", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(systemImageName: "tag"), userInfo: nil)
            
            let shortCutItem2 = UIApplicationShortcutItem(type: "\(bundleIdentifier).OpenDiscover", localizedTitle: "Discover Restaurants", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(systemImageName: "eyes"), userInfo: nil)
            
            let shortCutItem3 = UIApplicationShortcutItem(type: "\(bundleIdentifier).NewRestaurant", localizedTitle: "New Restaurant", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .add), userInfo: nil)
            
            UIApplication.shared.shortcutItems = [shortCutItem1, shortCutItem2, shortCutItem3]
        }
    }
    
    final class MainSceneDelegate: UIResponder, UIWindowSceneDelegate {
        
        @Environment(\.openURL) private var openURL: OpenURLAction
        
        func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
            guard let shortcutItem = connectionOptions.shortcutItem else { return }
            
            handleQuickAction(shortcutItem: shortcutItem)
        }
        
        func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
            completionHandler(handleQuickAction(shortcutItem: shortcutItem))
        }
        
        private func handleQuickAction(shortcutItem: UIApplicationShortcutItem) -> Bool {
            let shortcutType = shortcutItem.type
            
            guard let shortcutIdentifier = shortcutType.components(separatedBy: ".").last else { return false }
            
            guard let url = URL(string: "booktrainingapp://actions/" + shortcutIdentifier) else {
                print("Failed to initiate the url")
                return false
            }
            
            openURL(url)
            
            return true
        }
    }
    
    final class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
        func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
            let configuration = UISceneConfiguration(name: "Main Scene", sessionRole: connectingSceneSession.role)
            
            configuration.delegateClass = MainSceneDelegate.self
            
            return configuration
        }
        
        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                if granted {
                    print("User notifications are allowed.")
                } else {
                    print("User notifications are not allowed.")
                }
            }
            
            UNUserNotificationCenter.current().delegate = self
            
            return true
        }
        
        func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
            if response.actionIdentifier == "booktraining.makeReservation" {
                print("Make reservation...")
                if let phone = response.notification.request.content.userInfo["phone"] {
                    let telURL = "tel://\(phone)"
                    if let url = URL(string: telURL) {
                        if UIApplication.shared.canOpenURL(url) {
                            print("calling \(telURL)")
                            UIApplication.shared.open(url)
                        }
                    }
                }
            }
            completionHandler()
        }
    }
}
