//
//  CoinTableViewCell.swift
//  CryptoApp
//
//  Created by Micah Njeru on 01/12/2025.
//

import Foundation
import UIKit

class CoinTableViewCell: UITableViewCell {
    static let reuseIdentifier = "CoinTableViewCell"
    
    private let coinIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .systemGray6
        imageView.layer.cornerRadius = 20
        return imageView
    }()
    
    private let rankLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let changeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        return label
    }()
    
    private let favoriteIndicator: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .systemYellow
        imageView.image = UIImage(systemName: "star.fill")
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var nameStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [nameLabel, symbolLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var priceStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [priceLabel, changeLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .trailing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(rankLabel)
        contentView.addSubview(coinIconImageView)
        contentView.addSubview(nameStackView)
        contentView.addSubview(priceStackView)
        contentView.addSubview(favoriteIndicator)
        
        NSLayoutConstraint.activate([
            rankLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            rankLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rankLabel.widthAnchor.constraint(equalToConstant: 30),
            
            coinIconImageView.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 8),
            coinIconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            coinIconImageView.widthAnchor.constraint(equalToConstant: 40),
            coinIconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            nameStackView.leadingAnchor.constraint(equalTo: coinIconImageView.trailingAnchor, constant: 12),
            nameStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameStackView.trailingAnchor.constraint(lessThanOrEqualTo: priceStackView.leadingAnchor, constant: -12),
            
            priceStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            priceStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            priceStackView.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
            
            favoriteIndicator.trailingAnchor.constraint(equalTo: coinIconImageView.trailingAnchor, constant: 4),
            favoriteIndicator.bottomAnchor.constraint(equalTo: coinIconImageView.bottomAnchor, constant: 4),
            favoriteIndicator.widthAnchor.constraint(equalToConstant: 16),
            favoriteIndicator.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    func configure(with coin: Coin, isFavorite: Bool) {
        rankLabel.text = "#\(coin.rank)"
        nameLabel.text = coin.name
        symbolLabel.text = coin.symbol
        priceLabel.text = coin.formattedPrice
        
        changeLabel.text = "  \(coin.formattedChange)  "
        if coin.isPositiveChange {
            changeLabel.textColor = .systemGreen
            changeLabel.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
        } else {
            changeLabel.textColor = .systemRed
            changeLabel.backgroundColor = UIColor.systemRed.withAlphaComponent(0.15)
        }
        
        favoriteIndicator.isHidden = !isFavorite
        
        coinIconImageView.image = nil
        if let iconUrl = coin.iconUrl {
            Task {
                let image = await ImageCacheService.shared.image(for: iconUrl)
                if let image = image {
                    self.coinIconImageView.image = image
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        coinIconImageView.image = nil
        favoriteIndicator.isHidden = true
    }
}
