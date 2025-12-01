//
//  FavoriteCoinTableViewCell.swift
//  CryptoApp
//
//  Created by Micah Njeru on 01/12/2025.
//

import UIKit

class FavoriteCoinTableViewCell: UITableViewCell {
    static let reuseIdentifier = "FavoriteCoinTableViewCell"
    
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
    
    private let favoriteStarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .systemYellow
        imageView.image = UIImage(systemName: "star.fill")
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
        contentView.addSubview(favoriteStarImageView)
        
        NSLayoutConstraint.activate([
            rankLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            rankLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rankLabel.widthAnchor.constraint(equalToConstant: 30),
            
            coinIconImageView.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 8),
            coinIconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            coinIconImageView.widthAnchor.constraint(equalToConstant: 40),
            coinIconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            favoriteStarImageView.trailingAnchor.constraint(equalTo: coinIconImageView.trailingAnchor, constant: 4),
            favoriteStarImageView.bottomAnchor.constraint(equalTo: coinIconImageView.bottomAnchor, constant: 4),
            favoriteStarImageView.widthAnchor.constraint(equalToConstant: 16),
            favoriteStarImageView.heightAnchor.constraint(equalToConstant: 16),
            
            nameStackView.leadingAnchor.constraint(equalTo: coinIconImageView.trailingAnchor, constant: 12),
            nameStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameStackView.trailingAnchor.constraint(lessThanOrEqualTo: priceStackView.leadingAnchor, constant: -12),
            
            priceStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            priceStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            priceStackView.widthAnchor.constraint(greaterThanOrEqualToConstant: 100)
        ])
    }
    
    func configure(with favorite: FavoriteCoin) {
        rankLabel.text = "#\(favorite.rank)"
        nameLabel.text = favorite.name
        symbolLabel.text = favorite.symbol
        priceLabel.text = favorite.formattedPrice
        
        changeLabel.text = "  \(favorite.formattedChange)  "
        if favorite.isPositiveChange {
            changeLabel.textColor = .systemGreen
            changeLabel.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
        } else {
            changeLabel.textColor = .systemRed
            changeLabel.backgroundColor = UIColor.systemRed.withAlphaComponent(0.15)
        }
        
        coinIconImageView.image = nil
        if let iconUrl = favorite.iconUrl {
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
    }
}
