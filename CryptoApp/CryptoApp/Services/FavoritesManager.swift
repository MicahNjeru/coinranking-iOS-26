//
//  FavoritesManager.swift
//  CryptoApp
//
//  Created by Micah Njeru on 30/11/2025.
//

import Foundation
import Combine

@MainActor
class FavoritesManager: ObservableObject {
    @Published var favorites: [FavoriteCoin] = []
    @Published var favoriteUUIDs: Set<String> = []
    
    static let shared = FavoritesManager()
    
    private init() {
        loadFavorites()
        setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleFavoriteChange),
            name: .favoriteAdded,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleFavoriteChange),
            name: .favoriteRemoved,
            object: nil
        )
    }
    
    @objc private func handleFavoriteChange() {
        loadFavorites()
    }
    
    func loadFavorites() {
        favorites = CoreDataService.shared.fetchAllFavorites()
        favoriteUUIDs = Set(favorites.map { $0.uuid })
    }
    
    func isFavorite(_ uuid: String) -> Bool {
        favoriteUUIDs.contains(uuid)
    }
    
    func toggleFavorite(coin: Coin) {
        _ = CoreDataService.shared.toggleFavoriteWithNotification(coin: coin)
        loadFavorites()
    }
}
