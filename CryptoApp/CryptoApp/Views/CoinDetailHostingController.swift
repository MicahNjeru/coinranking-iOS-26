//
//  CoinDetailHostingController.swift
//  CryptoApp
//
//  Created by Micah Njeru on 30/11/2025.
//

import UIKit
import SwiftUI

class CoinDetailHostingController: UIHostingController<CoinDetailView> {
    
    init(coin: Coin) {
        let detailView = CoinDetailView(coin: coin)
        super.init(rootView: detailView)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
    }
}
