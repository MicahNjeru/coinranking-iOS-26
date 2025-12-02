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
    private let placeholderImage: UIImage = {
        // Try an app asset named "coinPlaceholder"; if missing, fall back to an SF Symbol.
        if let asset = UIImage(named: "coinPlaceholder") {
            return asset
        }
        return UIImage(systemName: "bitcoinsign.circle.fill") ?? UIImage()
    }()
    
    private init() {}
    
    func image(for urlString: String) async -> UIImage? {
        // If the URL isn't a PNG, use a placeholder to avoid decoding unsupported formats (e.g., SVG)
        if let ext = URL(string: urlString)?.pathExtension.lowercased(), ext != "png" {
            return placeholderImage
        }
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
        // Guard against unsupported formats (e.g., SVG). We only attempt to decode PNGs here.
        if let ext = URL(string: urlString)?.pathExtension.lowercased(), ext != "png" {
            print("[ImageDebug] Non-PNG icon detected (\(ext)). Using placeholder for: \(urlString)")
            return placeholderImage
        }
        
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                return image
            } else {
                print("[ImageDebug] Failed to decode image data. Using placeholder for: \(urlString)")
                return placeholderImage
            }
        } catch {
            print("Failed to download image: \(error.localizedDescription)")
            return nil
        }
    }
    
    func clearCache() {
        cache.removeAll()
    }
}

