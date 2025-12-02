//
//  CoinDetailView.swift
//  CryptoApp
//
//  Created by Micah Njeru on 30/11/2025.
//

import SwiftUI
import Charts

struct CoinDetailView: View {
    @StateObject private var viewModel: CoinDetailViewModel
    let coin: Coin
    
    init(coin: Coin) {
        self.coin = coin
        _viewModel = StateObject(wrappedValue: CoinDetailViewModel(coin: coin))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                chartSection
                
                if let detail = viewModel.coinDetail {
                    statisticsSection(detail: detail)
                }
                
                if let detail = viewModel.coinDetail, let description = detail.description {
                    descriptionSection(description: description)
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.toggleFavorite()
                }) {
                    Image(systemName: viewModel.isFavorite ? "star.fill" : "star")
                        .foregroundColor(viewModel.isFavorite ? .yellow : .gray)
                }
            }
        }
        .task {
            await viewModel.loadData()
        }
        .overlay {
            if viewModel.isLoading && viewModel.coinDetail == nil {
                ProgressView()
                    .scaleEffect(1.5)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            let url = URL(string: coin.iconUrl ?? "")
            let isPNG = (url?.pathExtension.lowercased() == "png")
            Group {
                if !isPNG {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.blue)
                } else {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                        case .failure(_), .empty:
                            Image(systemName: "bitcoinsign.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(.blue)
                        @unknown default:
                            Image(systemName: "bitcoinsign.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(.blue)
                        }
                    }
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            
            VStack(spacing: 4) {
                Text(coin.name)
                    .font(.title.bold())
                
                Text(coin.symbol)
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            Text(viewModel.formattedPrice)
                .font(.system(size: 36, weight: .bold))
            
            Text(viewModel.formattedChange)
                .font(.title3.bold())
                .foregroundColor(viewModel.isPositiveChange ? .green : .red)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    (viewModel.isPositiveChange ? Color.green : Color.red)
                        .opacity(0.15)
                )
                .cornerRadius(8)
        }
    }
    
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Price Chart")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(TimePeriod.allCases, id: \.self) { period in
                        Button(action: {
                            viewModel.changeTimePeriod(period)
                        }) {
                            Text(period.rawValue)
                                .font(.subheadline.bold())
                                .foregroundColor(
                                    viewModel.selectedTimePeriod == period ? .white : .primary
                                )
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    viewModel.selectedTimePeriod == period
                                        ? viewModel.chartColor
                                        : Color.gray.opacity(0.2)
                                )
                                .cornerRadius(20)
                        }
                    }
                }
            }
            
            if !viewModel.priceHistory.isEmpty {
                Chart {
                    ForEach(viewModel.priceHistory) { dataPoint in
                        LineMark(
                            x: .value("Time", dataPoint.date),
                            y: .value("Price", dataPoint.priceValue)
                        )
                        .foregroundStyle(viewModel.chartColor)
                        .interpolationMethod(.catmullRom)
                        
                        AreaMark(
                            x: .value("Time", dataPoint.date),
                            y: .value("Price", dataPoint.priceValue)
                        )
                        .foregroundStyle(
                            viewModel.chartColor.opacity(0.1).gradient
                        )
                        .interpolationMethod(.catmullRom)
                    }
                }
                .chartYScale(domain: .automatic(includesZero: false))
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 5)) { value in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
                .frame(height: 250)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 250)
                    .overlay(
                        ProgressView()
                    )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private func statisticsSection(detail: CoinDetail) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Statistics")
                .font(.headline)
            
            VStack(spacing: 12) {
                StatRow(title: "Rank", value: "#\(detail.rank)")
                StatRow(title: "Market Cap", value: formatMarketCap(detail.marketCap))
                if let volume = detail.volume24h {
                    StatRow(title: "24h Volume", value: formatMarketCap(volume))
                }
                
                if let supply = detail.supply, let circulating = supply.circulating {
                    StatRow(
                        title: "Circulating Supply",
                        value: formatSupply(circulating, symbol: detail.symbol)
                    )
                }
                
                if let supply = detail.supply, let total = supply.total {
                    StatRow(
                        title: "Total Supply",
                        value: formatSupply(total, symbol: detail.symbol)
                    )
                }
                
                StatRow(title: "Number of Markets", value: "\(detail.numberOfMarkets)")
                StatRow(title: "Number of Exchanges", value: "\(detail.numberOfExchanges)")
                
                if let ath = detail.allTimeHigh {
                    StatRow(title: "All Time High", value: formatPrice(ath.price))
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private func descriptionSection(description: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About \(coin.name)")
                .font(.headline)
            
            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private func formatMarketCap(_ value: String) -> String {
        guard let doubleValue = Double(value) else { return "$0" }
        
        if doubleValue >= 1_000_000_000_000 {
            return String(format: "$%.2fT", doubleValue / 1_000_000_000_000)
        } else if doubleValue >= 1_000_000_000 {
            return String(format: "$%.2fB", doubleValue / 1_000_000_000)
        } else if doubleValue >= 1_000_000 {
            return String(format: "$%.2fM", doubleValue / 1_000_000)
        } else {
            return String(format: "$%.2f", doubleValue)
        }
    }
    
    private func formatSupply(_ value: String, symbol: String) -> String {
        guard let doubleValue = Double(value) else { return "0" }
        
        if doubleValue >= 1_000_000_000 {
            return String(format: "%.2fB %@", doubleValue / 1_000_000_000, symbol)
        } else if doubleValue >= 1_000_000 {
            return String(format: "%.2fM %@", doubleValue / 1_000_000, symbol)
        } else {
            return String(format: "%.2f %@", doubleValue, symbol)
        }
    }
    
    private func formatPrice(_ value: String) -> String {
        guard let priceDouble = Double(value) else { return "$0.00" }
        if priceDouble >= 1 {
            return String(format: "$%.2f", priceDouble)
        } else {
            return String(format: "$%.6f", priceDouble)
        }
    }
}

struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 4)
    }
}
