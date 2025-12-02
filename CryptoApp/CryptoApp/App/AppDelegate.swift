//
//  AppDelegate.swift
//  CryptoApp
//
//  Created by Micah Njeru on 30/11/2025.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("🚀 AppDelegate didFinishLaunchingWithOptions")
        return true
    }

    // UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        print("🧩 AppDelegate configurationForConnecting: role=\(connectingSceneSession.role.rawValue)")
        let config = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self  // Force the correct delegate
        return config
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        print("🧹 AppDelegate didDiscardSceneSessions count=\(sceneSessions.count)")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("🛑 AppDelegate applicationWillTerminate -> saving Core Data")
        CoreDataService.shared.saveContext()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("🌙 AppDelegate applicationDidEnterBackground -> saving Core Data")
        CoreDataService.shared.saveContext()
    }
}
