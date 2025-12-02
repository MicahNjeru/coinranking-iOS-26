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

    // Custom Decoder (Fix null sparkline values)
    enum CodingKeys: String, CodingKey {
        case uuid
        case symbol
        case name
        case color
        case iconUrl
        case marketCap
        case price
        case listedAt
        case tier
        case change
        case rank
        case sparkline
        case lowVolume
        case coinrankingUrl
        case btcPrice
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        uuid = try container.decode(String.self, forKey: .uuid)
        symbol = try container.decode(String.self, forKey: .symbol)
        name = try container.decode(String.self, forKey: .name)
        color = try container.decodeIfPresent(String.self, forKey: .color)
        iconUrl = try container.decodeIfPresent(String.self, forKey: .iconUrl)
        marketCap = try container.decode(String.self, forKey: .marketCap)
        price = try container.decode(String.self, forKey: .price)
        listedAt = try container.decode(Int.self, forKey: .listedAt)
        tier = try container.decode(Int.self, forKey: .tier)
        change = try container.decode(String.self, forKey: .change)
        rank = try container.decode(Int.self, forKey: .rank)
        lowVolume = try container.decode(Bool.self, forKey: .lowVolume)
        coinrankingUrl = try container.decode(String.self, forKey: .coinrankingUrl)
        btcPrice = try container.decode(String.self, forKey: .btcPrice)

        // Fix: filter out null sparkline values
        let rawSparkline = try container.decodeIfPresent([String?].self, forKey: .sparkline)
        sparkline = rawSparkline?.compactMap { $0 }
    }
    
    // Prevent preview from requiring custom initializer
    init(
        uuid: String,
        symbol: String,
        name: String,
        color: String? = nil,
        iconUrl: String? = nil,
        marketCap: String,
        price: String,
        listedAt: Int,
        tier: Int,
        change: String,
        rank: Int,
        sparkline: [String]? = nil,
        lowVolume: Bool,
        coinrankingUrl: String,
        btcPrice: String
    ) {
        self.uuid = uuid
        self.symbol = symbol
        self.name = name
        self.color = color
        self.iconUrl = iconUrl
        self.marketCap = marketCap
        self.price = price
        self.listedAt = listedAt
        self.tier = tier
        self.change = change
        self.rank = rank
        self.sparkline = sparkline
        self.lowVolume = lowVolume
        self.coinrankingUrl = coinrankingUrl
        self.btcPrice = btcPrice
    }

    
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

