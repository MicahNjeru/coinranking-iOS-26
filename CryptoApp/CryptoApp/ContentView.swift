//
//  ContentView.swift
//  CryptoApp
//
//  Created by Micah Njeru on 30/11/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

#if DEBUG
struct CoinDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CoinDetailView(coin: Coin(
                uuid: "Qwsogvtv82FCd",
                symbol: "BTC",
                name: "Bitcoin",
                color: "#f7931A",
                iconUrl: "https://cdn.coinranking.com/bOabBYkcX/bitcoin_btc.svg",
                marketCap: "1234567890000",
                price: "45000.50",
                listedAt: 1330214400,
                tier: 1,
                change: "2.5",
                rank: 1,
                sparkline: ["44000", "44500", "45000"],
                lowVolume: false,
                coinrankingUrl: "https://coinranking.com/coin/Qwsogvtv82FCd+bitcoin-btc",
                btcPrice: "1"
            ))
        }
    }
}
#endif

// Custom AsyncImage with Cache
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder
    
    @State private var image: UIImage?
    
    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let image = image {
                content(Image(uiImage: image))
            } else {
                placeholder()
            }
        }
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        guard let url = url else { return }
        let urlString = url.absoluteString
        
        if let cachedImage = await ImageCacheService.shared.image(for: urlString) {
            self.image = cachedImage
        }
    }
}

// Error Handling View
struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Oops!")
                .font(.title.bold())
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: retryAction) {
                Text("Retry")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}
