//
//  CoinsListViewModel.swift
//  CryptoApp
//
//  Created by Micah Njeru on 30/11/2025.
//

import Foundation
import Combine

@MainActor
class CoinsListViewModel: ObservableObject {
    @Published var coins: [Coin] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasMorePages = true
    @Published var favoriteUUIDs: Set<String> = []
    
    private var currentOffset = 0
    private let limit = Constants.coinsPerPage
    private var currentSortOption: SortOption?
    private var isDescending = true
    
    init() {
        loadFavoriteUUIDs()
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
        loadFavoriteUUIDs()
    }
    
    func loadFavoriteUUIDs() {
        let favorites = CoreDataService.shared.fetchAllFavorites()
        favoriteUUIDs = Set(favorites.map { $0.uuid })
    }
    
    func isFavorite(_ uuid: String) -> Bool {
        favoriteUUIDs.contains(uuid)
    }
    
    func fetchCoins(refresh: Bool = false) async {
        print("🔎 fetchCoins(refresh: \(refresh), limit: \(limit))")
        guard !isLoading else { return }
        
        if refresh {
            currentOffset = 0
            hasMorePages = true
        }
        
        guard hasMorePages else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let orderBy = currentSortOption?.orderBy
            let orderDirection = isDescending ? "desc" : "asc"
            
            let response = try await NetworkService.shared.fetchCoins(
                offset: currentOffset,
                limit: limit,
                orderBy: orderBy,
                orderDirection: orderDirection
            )
            
            if refresh {
                print("📈 coins updated: \(self.coins.count)")
                coins = response.data.coins
            } else {
                coins.append(contentsOf: response.data.coins)
            }
            
            currentOffset += limit
            hasMorePages = coins.count < Constants.totalCoins && !response.data.coins.isEmpty
            CoreDataService.shared.updateFavorites(with: coins)
            
        } catch {
            print("⚠️ errorMessage: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func applySorting(_ sortOption: SortOption, descending: Bool = true) async {
        currentSortOption = sortOption
        isDescending = descending
        await fetchCoins(refresh: true)
    }
    
    func clearSorting() async {
        currentSortOption = nil
        isDescending = true
        await fetchCoins(refresh: true)
    }
    
    func toggleFavorite(for coin: Coin) {
        _ = CoreDataService.shared.toggleFavorite(coin: coin)
    }
}
