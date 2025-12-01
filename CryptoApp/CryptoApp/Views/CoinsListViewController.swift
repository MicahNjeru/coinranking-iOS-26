//
//  CoinsListViewController.swift
//  CryptoApp
//
//  Created by Micah Njeru on 30/11/2025.
//

import UIKit
import Combine

class CoinsListViewController: UIViewController {
    
    private let viewModel = CoinsListViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.delegate = self
        table.dataSource = self
        table.register(CoinTableViewCell.self, forCellReuseIdentifier: CoinTableViewCell.reuseIdentifier)
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
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var filterButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal.decrease.circle"),
            style: .plain,
            target: self,
            action: #selector(showFilterOptions)
        )
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("📄 CoinsListViewController viewDidLoad")
        setupUI()
        setupBindings()
        loadInitialData()
    }
    
    private func setupUI() {
        title = "Cryptocurrencies"
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = filterButton
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        
        tableView.refreshControl = refreshControl
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.$coins
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading && self?.viewModel.coins.isEmpty == true {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
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
        
        viewModel.$favoriteUUIDs
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func loadInitialData() {
        print("⬇️ CoinsListViewController loadInitialData")
        Task {
            await viewModel.fetchCoins(refresh: true)
        }
    }
    
    @objc private func handleRefresh() {
        Task {
            await viewModel.fetchCoins(refresh: true)
            refreshControl.endRefreshing()
        }
    }
    
    @objc private func showFilterOptions() {
        let alert = UIAlertController(
            title: "Sort By",
            message: "Choose a sorting option",
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: "Market Cap (Default)", style: .default) { [weak self] _ in
            Task {
                await self?.viewModel.clearSorting()
            }
        })
        
        alert.addAction(UIAlertAction(title: "Highest Price", style: .default) { [weak self] _ in
            Task {
                await self?.viewModel.applySorting(.price, descending: true)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Best 24h Performance", style: .default) { [weak self] _ in
            Task {
                await self?.viewModel.applySorting(.change24h, descending: true)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = filterButton
        }
        
        present(alert, animated: true)
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

extension CoinsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.coins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CoinTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? CoinTableViewCell else {
            return UITableViewCell()
        }
        
        let coin = viewModel.coins[indexPath.row]
        let isFavorite = viewModel.isFavorite(coin.uuid)
        cell.configure(with: coin, isFavorite: isFavorite)
        
        return cell
    }
}

extension CoinsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let coin = viewModel.coins[indexPath.row]
        
        let detailVC = CoinDetailHostingController(coin: coin)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let coin = viewModel.coins[indexPath.row]
        let isFavorite = viewModel.isFavorite(coin.uuid)
        
        let favoriteAction = UIContextualAction(
            style: .normal,
            title: isFavorite ? "Unfavorite" : "Favorite"
        ) { [weak self] _, _, completion in
            self?.viewModel.toggleFavorite(for: coin)
            
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            completion(true)
        }
        
        favoriteAction.backgroundColor = isFavorite ? .systemGray : .systemYellow
        favoriteAction.image = UIImage(systemName: isFavorite ? "star.slash" : "star.fill")
        
        return UISwipeActionsConfiguration(actions: [favoriteAction])
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.coins.count - 5 {
            Task {
                await viewModel.fetchCoins(refresh: false)
            }
        }
    }
}
