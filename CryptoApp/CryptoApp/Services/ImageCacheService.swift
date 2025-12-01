//
//  ImageCacheService.swift
//  CryptoApp
//
//  Created by Micah Njeru on 30/11/2025.
//

import Foundation
import UIKit

actor ImageCacheService {
    static let shared = ImageCacheService()
    
    private var cache: [String: UIImage] = [:]
    private var ongoingTasks: [String: Task<UIImage?, Never>] = [:]
    
    private init() {}
    
    func image(for urlString: String) async -> UIImage? {
        // Check cache first
        if let cachedImage = cache[urlString] {
            return cachedImage
        }
        
        // Check if there's an ongoing task
        if let ongoingTask = ongoingTasks[urlString] {
            return await ongoingTask.value
        }
        
        // Create new task
        let task = Task<UIImage?, Never> {
            await downloadImage(from: urlString)
        }
        
        ongoingTasks[urlString] = task
        
        let image = await task.value
        
        ongoingTasks[urlString] = nil
        
        if let image = image {
            cache[urlString] = image
        }
        
        return image
    }
    
    private func downloadImage(from urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            print("Failed to download image: \(error.localizedDescription)")
            return nil
        }
    }
    
    func clearCache() {
        cache.removeAll()
    }
}
