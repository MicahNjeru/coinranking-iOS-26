//
//  SceneDelegate.swift
//  CryptoApp
//
//  Created by Micah Njeru on 30/11/2025.
//

import Foundation
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print("🔌 SceneDelegate willConnectTo (scene: \(type(of: scene)))")
        guard let windowScene = (scene as? UIWindowScene) else {
            print("❌ SceneDelegate: Not a UIWindowScene")
            return
        }
        
        let window = UIWindow(windowScene: windowScene)
        
        // Create tab bar controller
        let tabBarController = MainTabBarController()
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        self.window = window
        window.makeKeyAndVisible()
        print("🪟 SceneDelegate: window visible, root = \(type(of: tabBarController))")
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        print("✅ SceneDelegate sceneDidDisconnect")
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        print("✅ SceneDelegate sceneDidBecomeActive")
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        print("⏸️ SceneDelegate sceneWillResignActive")
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        print("🌅 SceneDelegate sceneWillEnterForeground")
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Save Core Data context
        print("🌇 SceneDelegate sceneDidEnterBackground -> saving Core Data")
        CoreDataService.shared.saveContext()
    }
}
