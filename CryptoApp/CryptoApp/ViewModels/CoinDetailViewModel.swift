//
//  CoinDetailViewModel.swift
//  CryptoApp
//
//  Created by Micah Njeru on 30/11/2025.
//

import Foundation
import SwiftUI
import Charts
import Combine

@MainActor
class CoinDetailViewModel: ObservableObject {
    @Published var coinDetail: CoinDetail?
    @Published var priceHistory: [PriceHistory] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedTimePeriod: TimePeriod = .hour24
    @Published var isFavorite = false
    
    private let coinUUID: String
    private let coin: Coin
    
    init(coin: Coin) {
        self.coin = coin
        self.coinUUID = coin.uuid
        self.isFavorite = CoreDataService.shared.isFavorite(uuid: coin.uuid)
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
    
    @objc private func handleFavoriteChange(_ notification: Notification) {
        if let uuid = notification.userInfo?["uuid"] as? String, uuid == coinUUID {
            isFavorite = CoreDataService.shared.isFavorite(uuid: coinUUID)
        }
    }
    
    func loadData() async {
        await fetchCoinDetail()
        await fetchPriceHistory()
    }
    
    func fetchCoinDetail() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await NetworkService.shared.fetchCoinDetail(uuid: coinUUID)
            coinDetail = response.data.coin
        } catch {
            errorMessage = "Failed to load coin details: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func fetchPriceHistory() async {
        errorMessage = nil
        
        do {
            let response = try await NetworkService.shared.fetchCoinHistory(
                uuid: coinUUID,
                timePeriod: selectedTimePeriod.rawValue
            )
            // Filter out entries with nil or non-positive price values, then reverse to oldest-first
            let filtered = response.data.history.filter { item in
                if let priceString = item.price, let value = Double(priceString), value > 0 {
                    return true
                }
                return false
            }
            priceHistory = filtered.reversed()
        } catch {
            errorMessage = "Failed to load price history: \(error.localizedDescription)"
        }
    }
    
    func toggleFavorite() {
        _ = CoreDataService.shared.toggleFavoriteWithNotification(coin: coin)
    }
    
    func changeTimePeriod(_ period: TimePeriod) {
        selectedTimePeriod = period
        Task {
            await fetchPriceHistory()
        }
    }
    
    // Computed Properties
    var currentPrice: String {
        coinDetail?.price ?? coin.price
    }
    
    var formattedPrice: String {
        guard let priceDouble = Double(currentPrice) else { return "$0.00" }
        if priceDouble >= 1 {
            return String(format: "$%.2f", priceDouble)
        } else {
            return String(format: "$%.6f", priceDouble)
        }
    }
    
    var change24h: String {
        coinDetail?.change ?? coin.change
    }
    
    var formattedChange: String {
        guard let changeDouble = Double(change24h) else { return "0.00%" }
        let sign = changeDouble >= 0 ? "+" : ""
        return String(format: "%@%.2f%%", sign, changeDouble)
    }
    
    var isPositiveChange: Bool {
        (Double(change24h) ?? 0) >= 0
    }
    
    var chartColor: Color {
        isPositiveChange ? .green : .red
    }
}

