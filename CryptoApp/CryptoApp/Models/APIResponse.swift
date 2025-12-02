//
//  APIResponse.swift
//  CryptoApp
//
//  Created by Micah Njeru on 30/11/2025.
//

import Foundation

struct CoinsResponse: Codable {
    let status: String
    let data: CoinsData
}

struct CoinsData: Codable {
    let stats: CoinStats
    let coins: [Coin]
}

struct CoinStats: Codable {
    let total: Int
    let totalCoins: Int
    let totalMarkets: Int
    let totalExchanges: Int
    let totalMarketCap: String
    let total24hVolume: String
}

struct CoinDetailResponse: Codable {
    let status: String
    let data: CoinDetailData
}

struct CoinDetailData: Codable {
    let coin: CoinDetail
}

struct CoinDetail: Codable {
    let uuid: String
    let symbol: String
    let name: String
    let description: String?
    let color: String?
    let iconUrl: String?
    let websiteUrl: String?
    let price: String
    let marketCap: String
    let volume24h: String?
    let change: String
    let rank: Int
    let numberOfMarkets: Int
    let numberOfExchanges: Int
    let supply: Supply?
    let allTimeHigh: AllTimeHigh?
    let sparkline: [String]?

    enum CodingKeys: String, CodingKey {
        case uuid
        case symbol
        case name
        case description
        case color
        case iconUrl
        case websiteUrl
        case price
        case marketCap
        case volume24h
        case change
        case rank
        case numberOfMarkets
        case numberOfExchanges
        case supply
        case allTimeHigh
        case sparkline
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uuid = try container.decode(String.self, forKey: .uuid)
        symbol = try container.decode(String.self, forKey: .symbol)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        color = try container.decodeIfPresent(String.self, forKey: .color)
        iconUrl = try container.decodeIfPresent(String.self, forKey: .iconUrl)
        websiteUrl = try container.decodeIfPresent(String.self, forKey: .websiteUrl)
        price = try container.decode(String.self, forKey: .price)
        marketCap = try container.decode(String.self, forKey: .marketCap)
        volume24h = try container.decodeIfPresent(String.self, forKey: .volume24h)
        change = try container.decode(String.self, forKey: .change)
        rank = try container.decode(Int.self, forKey: .rank)
        numberOfMarkets = try container.decode(Int.self, forKey: .numberOfMarkets)
        numberOfExchanges = try container.decode(Int.self, forKey: .numberOfExchanges)
        supply = try container.decodeIfPresent(Supply.self, forKey: .supply)
        allTimeHigh = try container.decodeIfPresent(AllTimeHigh.self, forKey: .allTimeHigh)
        sparkline = try container.decodeIfPresent([String].self, forKey: .sparkline)

        // Print statements to find issue with some icons working and others not working
        if iconUrl == nil || iconUrl?.isEmpty == true {
            print("[ImageDebug] Missing iconUrl for coin: \(name) (uuid: \(uuid))")
            print(iconURL ?? "No url")
        } else if URL(string: iconUrl!) == nil {
            print("[ImageDebug] Invalid iconUrl for coin: \(name) (uuid: \(uuid)) -> \(iconUrl!)")
        } else {
            print("[ImageDebug] iconUrl OK for coin: \(name) (uuid: \(uuid))")
            print(iconURL ?? "✅ Okay url print statement")
        }
    }

    var iconURL: URL? {
        guard let iconUrl = iconUrl, !iconUrl.isEmpty else {
            print("[ImageDebug] Missing iconUrl for coin: \(name) (uuid: \(uuid))")
            return nil
        }
        guard let url = URL(string: iconUrl) else {
            print("[ImageDebug] Invalid iconUrl for coin: \(name) (uuid: \(uuid)) -> \(iconUrl)")
            return nil
        }
        return url
    }
}

struct Supply: Codable {
    let confirmed: Bool
    let circulating: String?
    let total: String?
}

struct AllTimeHigh: Codable {
    let price: String
    let timestamp: Int
}

struct CoinHistoryResponse: Codable {
    let status: String
    let data: CoinHistoryData
}

struct CoinHistoryData: Codable {
    let change: String
    let history: [PriceHistory]
}

struct PriceHistory: Codable, Identifiable {
    let price: String?
    let timestamp: Int
    
    var id: Int { timestamp }
    
    var priceValue: Double {
        guard let price = price, let value = Double(price) else { return 0.0 }
        return value
    }
    
    var date: Date {
        Date(timeIntervalSince1970: TimeInterval(timestamp))
    }
}
