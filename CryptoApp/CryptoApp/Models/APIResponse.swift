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
    let price: String
    let timestamp: Int
    
    var id: Int { timestamp }
    
    var priceValue: Double {
        Double(price) ?? 0.0
    }
    
    var date: Date {
        Date(timeIntervalSince1970: TimeInterval(timestamp))
    }
}
