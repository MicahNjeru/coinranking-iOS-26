//
//  FavoriteCoin+CoreDataProperties.swift
//  CryptoApp
//
//  Created by Micah Njeru on 30/11/2025.
//

import Foundation
import CoreData

extension FavoriteCoin {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteCoin> {
        return NSFetchRequest<FavoriteCoin>(entityName: "FavoriteCoin")
    }
    
    @NSManaged public var uuid: String
    @NSManaged public var name: String
    @NSManaged public var symbol: String
    @NSManaged public var price: String
    @NSManaged public var change: String
    @NSManaged public var iconUrl: String?
    @NSManaged public var color: String?
    @NSManaged public var rank: Int64
    @NSManaged public var marketCap: String
    @NSManaged public var dateAdded: Date
    
    var priceValue: Double {
        Double(price) ?? 0.0
    }
    
    var changeValue: Double {
        Double(change) ?? 0.0
    }
    
    var formattedPrice: String {
        guard let priceDouble = Double(price) else { return "$0.00" }
        if priceDouble >= 1 {
            return String(format: "$%.2f", priceDouble)
        } else {
            return String(format: "$%.6f", priceDouble)
        }
    }
    
    var formattedChange: String {
        guard let changeDouble = Double(change) else { return "0.00%" }
        let sign = changeDouble >= 0 ? "+" : ""
        return String(format: "%@%.2f%%", sign, changeDouble)
    }
    
    var isPositiveChange: Bool {
        changeValue >= 0
    }
}

extension FavoriteCoin: Identifiable {
    public var id: String { uuid }
}
