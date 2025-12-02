//
//  MainTabBarController.swift
//  CryptoApp
//
//  Created by Micah Njeru on 30/11/2025.
//

import Foundation
import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("🧭 MainTabBarController viewDidLoad")
        
        setupViewControllers()
        print("🧭 MainTabBarController setupViewControllers done. viewControllers count=\(viewControllers?.count ?? 0)")
        
        configureTabBarAppearance()
        print("🎨 MainTabBarController appearance configured")
        
        // Set default selected tab
        selectedIndex = 0
        print("🔢 MainTabBarController selectedIndex=\(selectedIndex)")
    }
    
    private func setupViewControllers() {
        // 1. Coins List Tab
        let coinsVC = CoinsListViewController()
        let coinsNavController = UINavigationController(rootViewController: coinsVC)
        coinsNavController.tabBarItem = UITabBarItem(
            title: "Cryptocurrencies",
            image: UIImage(systemName: "chart.line.uptrend.xyaxis"),
            selectedImage: UIImage(systemName: "chart.line.uptrend.xyaxis.fill")
        )
        
        // 2. Favorites Tab
        let favoritesVC = FavoritesViewController()
        let favoritesNavController = UINavigationController(rootViewController: favoritesVC)
        favoritesNavController.tabBarItem = UITabBarItem(
            title: "Favorites",
            image: UIImage(systemName: "star"),
            selectedImage: UIImage(systemName: "star.fill")
        )
        
        // Set view controllers
        viewControllers = [coinsNavController, favoritesNavController]
    }
    
    private func configureTabBarAppearance() {
        // Customize tab bar appearance
        tabBar.isTranslucent = true
        
        // Badge appearance
        if #available(iOS 13.0, *) {
            let appearance = tabBar.standardAppearance
            appearance.stackedLayoutAppearance.normal.badgeBackgroundColor = .systemRed
            appearance.stackedLayoutAppearance.normal.badgeTextAttributes = [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 12, weight: .bold)
            ]
            tabBar.standardAppearance = appearance
        }
    }
}

// Enhanced MainTabBarController with Coordinator Pattern

protocol Coordinator {
    var navigationController: UINavigationController { get set }
    func start()
}

class CoinsCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let coinsVC = CoinsListViewController()
        navigationController.pushViewController(coinsVC, animated: false)
    }
    
    func showCoinDetail(coin: Coin) {
        let detailVC = CoinDetailHostingController(coin: coin)
        navigationController.pushViewController(detailVC, animated: true)
    }
}

class FavoritesCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let favoritesVC = FavoritesViewController()
        navigationController.pushViewController(favoritesVC, animated: false)
    }
    
    func showCoinDetail(coin: Coin) {
        let detailVC = CoinDetailHostingController(coin: coin)
        navigationController.pushViewController(detailVC, animated: true)
    }
}
