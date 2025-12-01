//
//  NetworkService.swift
//  CryptoApp
//
//  Created by Micah Njeru on 30/11/2025.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(Int)
    case networkError(Error)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received from server"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let code):
            return "Server error with code: \(code)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

class NetworkService {
    static let shared = NetworkService()
    
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Generic Request Method
    private func request<T: Codable>(endpoint: APIEndpoint, method: String = "GET") async throws -> T {
        guard let url = endpoint.url() else {
            print("❌ Network invalidURL: \(endpoint)")
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Secrets.coinRankingAPIKey, forHTTPHeaderField: "x-access-token")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Network unknown response")
                throw NetworkError.unknown
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("🚨 Server error: \(httpResponse.statusCode)")
                throw NetworkError.serverError(httpResponse.statusCode)
            }
            
            do {
                let decoder = JSONDecoder()
                let decoded = try decoder.decode(T.self, from: data)
                print("✅ Decoded \(T.self)")
                return decoded
            } catch {
                print("🧩 Decoding error: \(error)")
                throw NetworkError.decodingError(error)
            }
            
        } catch let error as NetworkError {
            print("🌩️ Network error: \(error)")
            throw error
        } catch {
            print("🌩️ URLSession error: \(error)")
            throw NetworkError.networkError(error)
        }
    }
    
    // MARK: - API Methods
    func fetchCoins(
        offset: Int = 0,
        limit: Int = Constants.coinsPerPage,
        orderBy: String? = nil,
        orderDirection: String? = nil
    ) async throws -> CoinsResponse {
        let endpoint = APIEndpoint.coins(
            offset: offset,
            limit: limit,
            orderBy: orderBy,
            orderDirection: orderDirection
        )
        return try await request(endpoint: endpoint)
    }
    
    func fetchCoinDetail(uuid: String) async throws -> CoinDetailResponse {
        let endpoint = APIEndpoint.coinDetail(uuid: uuid)
        return try await request(endpoint: endpoint)
    }
    
    func fetchCoinHistory(
        uuid: String,
        timePeriod: String = "24h"
    ) async throws -> CoinHistoryResponse {
        let endpoint = APIEndpoint.coinHistory(uuid: uuid, timePeriod: timePeriod)
        return try await request(endpoint: endpoint)
    }
}
