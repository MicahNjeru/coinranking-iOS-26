//
//  FavoritesViewController.swift
//  CryptoApp
//
//  Created by Micah Njeru on 30/11/2025.
//

import UIKit
import Combine

class FavoritesViewController: UIViewController {
    
    private let viewModel = FavoritesViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.delegate = self
        table.dataSource = self
        table.register(FavoriteCoinTableViewCell.self, forCellReuseIdentifier: FavoriteCoinTableViewCell.reuseIdentifier)
        table.rowHeight = 70
        table.separatorInset = UIEdgeInsets(top: 0, left: 78, bottom: 0, right: 0)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return refresh
    }()
    
    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView(image: UIImage(systemName: "star.slash"))
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "No Favorites Yet"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        
        let messageLabel = UILabel()
        messageLabel.text = "Swipe left on any coin to add it to your favorites"
        messageLabel.font = .systemFont(ofSize: 16)
        messageLabel.textColor = .secondaryLabel
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(messageLabel)
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("⭐ FavoritesViewController viewDidLoad")
        setupUI()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadFavorites()
    }
    
    private func setupUI() {
        title = "Favorites"
        view.backgroundColor = .systemBackground
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        
        tableView.refreshControl = refreshControl
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.$favorites
            .receive(on: DispatchQueue.main)
            .sink { [weak self] favorites in
                self?.updateUI(isEmpty: favorites.isEmpty)
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if !isLoading {
                    self?.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                if let error = errorMessage {
                    self?.showError(error)
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateUI(isEmpty: Bool) {
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
    
    @objc private func handleRefresh() {
        Task {
            await viewModel.refreshFavorites()
        }
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension FavoritesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: FavoriteCoinTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? FavoriteCoinTableViewCell else {
            return UITableViewCell()
        }
        
        let favorite = viewModel.favorites[indexPath.row]
        cell.configure(with: favorite)
        
        return cell
    }
}

extension FavoritesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let favorite = viewModel.favorites[indexPath.row]
        
        let coin = Coin(
            uuid: favorite.uuid,
            symbol: favorite.symbol,
            name: favorite.name,
            color: favorite.color,
            iconUrl: favorite.iconUrl,
            marketCap: favorite.marketCap,
            price: favorite.price,
            listedAt: 0,
            tier: 1,
            change: favorite.change,
            rank: Int(favorite.rank),
            sparkline: nil,
            lowVolume: false,
            coinrankingUrl: "",
            btcPrice: ""
        )
        
        let detailVC = CoinDetailHostingController(coin: coin)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let favorite = viewModel.favorites[indexPath.row]
        
        let unfavoriteAction = UIContextualAction(
            style: .destructive,
            title: "Unfavorite"
        ) { [weak self] _, _, completion in
            self?.viewModel.removeFavorite(uuid: favorite.uuid)
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            completion(true)
        }
        
        unfavoriteAction.image = UIImage(systemName: "star.slash.fill")
        unfavoriteAction.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [unfavoriteAction])
    }
}
