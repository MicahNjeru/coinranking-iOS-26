//
//  CoreDataService.swift
//  CryptoApp
//
//  Created by Micah Njeru on 30/11/2025.
//

import Foundation
import CoreData

class CoreDataService {
    static let shared = CoreDataService()
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CryptoApp")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private init() {}
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Failed to save context: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func addFavorite(coin: Coin) -> Bool {
        if isFavorite(uuid: coin.uuid) {
            return false
        }
        
        let favorite = FavoriteCoin(context: context)
        favorite.uuid = coin.uuid
        favorite.name = coin.name
        favorite.symbol = coin.symbol
        favorite.price = coin.price
        favorite.change = coin.change
        favorite.iconUrl = coin.iconUrl
        favorite.color = coin.color
        favorite.rank = Int64(coin.rank)
        favorite.marketCap = coin.marketCap
        favorite.dateAdded = Date()
        
        saveContext()
        
        NotificationCenter.default.post(name: .favoriteAdded, object: nil, userInfo: ["uuid": coin.uuid])
        
        return true
    }
    
    func removeFavorite(uuid: String) -> Bool {
        let fetchRequest: NSFetchRequest<FavoriteCoin> = FavoriteCoin.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", uuid)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let favorite = results.first {
                context.delete(favorite)
                saveContext()
                
                NotificationCenter.default.post(name: .favoriteRemoved, object: nil, userInfo: ["uuid": uuid])
                
                return true
            }
        } catch {
            print("Failed to remove favorite: \(error)")
        }
        
        return false
    }
    
    func toggleFavorite(coin: Coin) -> Bool {
        if isFavorite(uuid: coin.uuid) {
            removeFavorite(uuid: coin.uuid)
            return false
        } else {
            addFavorite(coin: coin)
            return true
        }
    }
    
    func toggleFavoriteWithNotification(coin: Coin) -> Bool {
        let wasFavorited = toggleFavorite(coin: coin)
        let name: Notification.Name = wasFavorited ? .favoriteAdded : .favoriteRemoved
        NotificationCenter.default.post(name: name, object: nil, userInfo: ["uuid": coin.uuid])
        return wasFavorited
    }
    
    func isFavorite(uuid: String) -> Bool {
        let fetchRequest: NSFetchRequest<FavoriteCoin> = FavoriteCoin.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", uuid)
        fetchRequest.fetchLimit = 1
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Failed to check favorite status: \(error)")
            return false
        }
    }
    
    func fetchAllFavorites() -> [FavoriteCoin] {
        let fetchRequest: NSFetchRequest<FavoriteCoin> = FavoriteCoin.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch favorites: \(error)")
            return []
        }
    }
    
    func getFavoriteCount() -> Int {
        let fetchRequest: NSFetchRequest<FavoriteCoin> = FavoriteCoin.fetchRequest()
        
        do {
            return try context.count(for: fetchRequest)
        } catch {
            print("Failed to get favorite count: \(error)")
            return 0
        }
    }
    
    func updateFavorites(with coins: [Coin]) {
        for coin in coins {
            if isFavorite(uuid: coin.uuid) {
                let fetchRequest: NSFetchRequest<FavoriteCoin> = FavoriteCoin.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "uuid == %@", coin.uuid)
                
                do {
                    let results = try context.fetch(fetchRequest)
                    if let favorite = results.first {
                        favorite.price = coin.price
                        favorite.change = coin.change
                        favorite.rank = Int64(coin.rank)
                        favorite.marketCap = coin.marketCap
                        saveContext()
                    }
                } catch {
                    print("Failed to update favorite: \(error)")
                }
            }
        }
    }
    
    func clearAllFavorites() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = FavoriteCoin.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            saveContext()
        } catch {
            print("Failed to clear favorites: \(error)")
        }
    }
}

