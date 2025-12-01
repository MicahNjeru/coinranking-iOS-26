//
//  Constants.swift
//  CryptoApp
//
//  Created by Micah Njeru on 30/11/2025.
//

import Foundation

enum Constants {
    static let baseURL = "https://api.coinranking.com/v2"
    static let coinsPerPage = 20
    static let totalCoins = 100
}

enum APIEndpoint {
    case coins(offset: Int, limit: Int, orderBy: String?, orderDirection: String?)
    case coinDetail(uuid: String)
    case coinHistory(uuid: String, timePeriod: String)
    
    var path: String {
        switch self {
        case .coins:
            return "/coins"
        case .coinDetail(let uuid):
            return "/coin/\(uuid)"
        case .coinHistory(let uuid, _):
            return "/coin/\(uuid)/history"
        }
    }
    
    func url() -> URL? {
        var components = URLComponents(string: Constants.baseURL + path)
        
        switch self {
        case .coins(let offset, let limit, let orderBy, let orderDirection):
            var queryItems = [
                URLQueryItem(name: "offset", value: "\(offset)"),
                URLQueryItem(name: "limit", value: "\(limit)")
            ]
            
            if let orderBy = orderBy {
                queryItems.append(URLQueryItem(name: "orderBy", value: orderBy))
            }
            
            if let orderDirection = orderDirection {
                queryItems.append(URLQueryItem(name: "orderDirection", value: orderDirection))
            }
            
            components?.queryItems = queryItems
            
        case .coinDetail:
            break
            
        case .coinHistory(_, let timePeriod):
            components?.queryItems = [
                URLQueryItem(name: "timePeriod", value: timePeriod)
            ]
        }
        
        return components?.url
    }
}

enum SortOption {
    case marketCap
    case price
    case change24h
    
    var orderBy: String {
        switch self {
        case .marketCap:
            return "marketCap"
        case .price:
            return "price"
        case .change24h:
            return "change"
        }
    }
}

enum TimePeriod: String, CaseIterable {
    case hour3 = "3h"
    case hour24 = "24h"
    case days7 = "7d"
    case days30 = "30d"
    case months3 = "3m"
    case year1 = "1y"
    case years3 = "3y"
    case years5 = "5y"
    
    var displayName: String {
        switch self {
        case .hour3: return "3 Hours"
        case .hour24: return "24 Hours"
        case .days7: return "7 Days"
        case .days30: return "30 Days"
        case .months3: return "3 Months"
        case .year1: return "1 Year"
        case .years3: return "3 Years"
        case .years5: return "5 Years"
        }
    }
}
