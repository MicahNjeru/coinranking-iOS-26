//
//  FavoritesViewModel.swift
//  CryptoApp
//
//  Created by Micah Njeru on 30/11/2025.
//

import Foundation
import Combine

@MainActor
class FavoritesViewModel: ObservableObject {
    @Published var favorites: [FavoriteCoin] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        setupNotifications()
        loadFavorites()
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
    }
    
    func removeFavorite(uuid: String) {
        _ = CoreDataService.shared.removeFavorite(uuid: uuid)
        loadFavorites()
    }
    
    func refreshFavorites() async {
        guard !favorites.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let uuids = favorites.map { $0.uuid }
            
            let response = try await NetworkService.shared.fetchCoins(
                offset: 0,
                limit: 100
            )
            
            let updatedCoins = response.data.coins.filter { uuids.contains($0.uuid) }
            
            CoreDataService.shared.updateFavorites(with: updatedCoins)
            
            loadFavorites()
            
        } catch {
            errorMessage = "Failed to refresh favorites: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    var isEmpty: Bool {
        favorites.isEmpty
    }
    
    var favoriteCount: Int {
        favorites.count
    }
}
