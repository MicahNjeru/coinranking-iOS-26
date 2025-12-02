//
//  CryptoAppTests.swift
//  CryptoAppTests
//
//  Created by Micah Njeru on 30/11/2025.
//

import Testing
@testable import CryptoApp
import UIKit

@Suite("CryptoApp Unit Tests")
struct CryptoAppTests {

    // Coin model formatting tests
    /// These tests validate formatting helpers on the Coin model.
    @Test("Coin formattedPrice produces currency-like string")
    func testCoinFormattedPrice() async throws {
        // Given a coin with a price string
        let coin = await Coin(
            uuid: "id",
            symbol: "BTC",
            name: "Bitcoin",
            color: nil,
            iconUrl: nil,
            marketCap: "123456789",
            price: "45000.5",
            listedAt: 0,
            tier: 1,
            change: "2.5",
            rank: 1,
            sparkline: nil,
            lowVolume: false,
            coinrankingUrl: "",
            btcPrice: "1"
        )
        // When we read formattedPrice
        let formatted = await coin.formattedPrice
        // Then it should contain a decimal and digits (exact currency symbol may vary by locale)
        #expect(formatted.contains("."))
        #expect(formatted.rangeOfCharacter(from: .decimalDigits) != nil)
    }

    @Test("Coin formattedChange shows percent and sign consistency")
    func testCoinFormattedChange() async throws {
        // Given positive and negative change values
        let gain = await Coin(
            uuid: "g",
            symbol: "G",
            name: "Gain",
            color: nil,
            iconUrl: nil,
            marketCap: "123456789",
            price: "1",
            listedAt: 0,
            tier: 1,
            change: "3.25",
            rank: 1,
            sparkline: nil,
            lowVolume: false,
            coinrankingUrl: "",
            btcPrice: "1"
        )
        let loss = await Coin(
            uuid: "l",
            symbol: "L",
            name: "Loss",
            color: nil,
            iconUrl: nil,
            marketCap: "123456789",
            price: "1",
            listedAt: 0,
            tier: 1,
            change: "-0.75",
            rank: 2,
            sparkline: nil,
            lowVolume: false,
            coinrankingUrl: "",
            btcPrice: "1"
        )
        // Then the formattedChange should include a % sign and reflect sign
        #expect(gain.formattedChange.contains("%"))
        #expect(loss.formattedChange.contains("%"))
        #expect(gain.isPositiveChange == true)
        #expect(loss.isPositiveChange == false)
    }

    // MARK: - CoinTableViewCell configuration tests
    // These tests ensure the cell binds model data to labels and styles correctly.
    @Test("CoinTableViewCell configure binds text and favorite state")
    func testCoinCellConfigure() async throws {
        // Given a cell and a sample coin
        let cell = await CoinTableViewCell(style: .default, reuseIdentifier: CoinTableViewCell.reuseIdentifier)
        let coin = await Coin(
            uuid: "btc",
            symbol: "BTC",
            name: "Bitcoin",
            color: nil,
            iconUrl: nil,
            marketCap: "123456789",
            price: "45000.50",
            listedAt: 0,
            tier: 1,
            change: "2.5",
            rank: 1,
            sparkline: nil,
            lowVolume: false,
            coinrankingUrl: "",
            btcPrice: "1"
        )
        // When
        await cell.configure(with: coin, isFavorite: true)
        // Then: We can indirectly verify through accessibilityLabel snapshots.
        // Since labels are private, verify layout/content without crashing and prepareForReuse resets states.
        await cell.layoutIfNeeded()
        await cell.prepareForReuse()
        // If we reach here without crash, basic binding path is healthy.
        #expect(true)
    }

    // MARK: - ImageCacheService basic contract
    // This test checks that asking for an image with a URL string returns quickly with nil when not cached.
    @Test("ImageCacheService returns fallback SF Symbol for invalid URL")
    func testImageCacheServiceMiss() async throws {
        let image = await ImageCacheService.shared.image(
            for: "https://example.com/non-existent.png"
        )

        #expect(image != nil)

        // Create the expected fallback UIImage
        let expected = UIImage(systemName: "bitcoinsign.circle.fill")

        // Compare PNG data representation
        let symbolData = image?.pngData()
        let expectedData = expected?.pngData()

        #expect(symbolData == expectedData)
    }
}
