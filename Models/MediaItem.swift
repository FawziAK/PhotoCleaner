//
//  MediaItem.swift
//  PhotoCleaner
//
//  Model for media items (photos and videos)
//

import Foundation
import Photos
import UIKit

struct MediaItem: Identifiable, Hashable {
    let id: String
    let asset: PHAsset
    let fileSize: Int64
    let creationDate: Date
    let mediaType: PHAssetMediaType
    let duration: TimeInterval
    let pixelWidth: Int
    let pixelHeight: Int
    let isScreenshot: Bool
    let isFavorite: Bool
    var contentHash: String?
    
    init(asset: PHAsset) {
        self.id = asset.localIdentifier
        self.asset = asset
        self.creationDate = asset.creationDate ?? Date()
        self.mediaType = asset.mediaType
        self.duration = asset.duration
        self.pixelWidth = asset.pixelWidth
        self.pixelHeight = asset.pixelHeight
        self.isFavorite = asset.isFavorite
        
        // Determine if it's a screenshot
        if #available(iOS 9.0, *) {
            self.isScreenshot = asset.mediaSubtypes.contains(.photoScreenshot)
        } else {
            self.isScreenshot = false
        }
        
        // Get file size
        let resources = PHAssetResource.assetResources(for: asset)
        var size: Int64 = 0
        
        for resource in resources {
            if let unsignedSize = resource.value(forKey: "fileSize") as? Int64 {
                size += unsignedSize
            }
        }
        
        self.fileSize = size
        
        // Generate content hash for duplicate detection
        self.contentHash = Self.generateHash(for: asset)
    }
    
    static func generateHash(for asset: PHAsset) -> String? {
        // Create a hash based on creation date and file size
        // In a real app, you might want to use image data hashing for better accuracy
        let dateString = asset.creationDate?.timeIntervalSince1970.description ?? ""
        let sizeString = "\(asset.pixelWidth)x\(asset.pixelHeight)"
        return "\(dateString)-\(sizeString)"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MediaItem, rhs: MediaItem) -> Bool {
        lhs.id == rhs.id
    }
    
    var formattedSize: String {
        return ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
    }
    
    var formattedDuration: String {
        guard duration > 0 else { return "" }
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var resolution: String {
        return "\(pixelWidth) × \(pixelHeight)"
    }
}

