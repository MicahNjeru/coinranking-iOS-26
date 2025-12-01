//
//  Coin.swift
//  CryptoApp
//
//  Created by Micah Njeru on 30/11/2025.
//

import Foundation

struct Coin: Codable, Identifiable {
    let uuid: String
    let symbol: String
    let name: String
    let color: String?
    let iconUrl: String?
    let marketCap: String
    let price: String
    let listedAt: Int
    let tier: Int
    let change: String
    let rank: Int
    let sparkline: [String]?
    let lowVolume: Bool
    let coinrankingUrl: String
    let btcPrice: String
    
    var id: String { uuid }
    
    // Computed properties
    var priceValue: Double {
        Double(price) ?? 0.0
    }
    
    var changeValue: Double {
        Double(change) ?? 0.0
    }
    
    var formattedPrice: String {
        guard let priceDouble = Double(price) else { return "$0.00" }
        if priceDouble >= 1 {
            return String(format: "$%.2f", priceDouble)
        } else {
            return String(format: "$%.6f", priceDouble)
        }
    }
    
    var formattedChange: String {
        guard let changeDouble = Double(change) else { return "0.00%" }
        let sign = changeDouble >= 0 ? "+" : ""
        return String(format: "%@%.2f%%", sign, changeDouble)
    }
    
    var isPositiveChange: Bool {
        changeValue >= 0
    }
}
