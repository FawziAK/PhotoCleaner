//
//  PhotoManager.swift
//  PhotoCleaner
//
//  Manager for photo library access and operations
//

import Foundation
import Photos
import UIKit

class PhotoManager: ObservableObject {
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    @Published var photos: [MediaItem] = []
    @Published var videos: [MediaItem] = []
    @Published var totalPhotos = 0
    @Published var totalVideos = 0
    @Published var totalSize: Int64 = 0
    @Published var isLoading = false
    
    init() {
        checkAuthorizationStatus()
    }
    
    func checkAuthorizationStatus() {
        authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }
    
    func requestPhotoLibraryAccess() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            DispatchQueue.main.async {
                self?.authorizationStatus = status
                if status == .authorized || status == .limited {
                    self?.loadAllMedia()
                }
            }
        }
    }
    
    func loadAllMedia() {
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            
            // Fetch photos
            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
            let photoAssets = PHAsset.fetchAssets(with: fetchOptions)
            
            // Fetch videos
            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
            let videoAssets = PHAsset.fetchAssets(with: fetchOptions)
            
            var photoItems: [MediaItem] = []
            var videoItems: [MediaItem] = []
            var totalSize: Int64 = 0
            
            // Process photos
            photoAssets.enumerateObjects { asset, _, _ in
                let item = MediaItem(asset: asset)
                photoItems.append(item)
                totalSize += item.fileSize
            }
            
            // Process videos
            videoAssets.enumerateObjects { asset, _, _ in
                let item = MediaItem(asset: asset)
                videoItems.append(item)
                totalSize += item.fileSize
            }
            
            DispatchQueue.main.async {
                self.photos = photoItems
                self.videos = videoItems
                self.totalPhotos = photoItems.count
                self.totalVideos = videoItems.count
                self.totalSize = totalSize
                self.isLoading = false
            }
        }
    }
    
    func deleteAssets(_ items: [MediaItem], completion: @escaping (Bool, Error?) -> Void) {
        let assets = items.compactMap { $0.asset }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(assets as NSFastEnumeration)
        }) { success, error in
            DispatchQueue.main.async {
                if success {
                    self.loadAllMedia() // Refresh the library
                }
                completion(success, error)
            }
        }
    }
    
    func findDuplicates() -> [[MediaItem]] {
        var duplicates: [[MediaItem]] = []
        var processedHashes: Set<String> = []
        
        let allMedia = photos + videos
        var hashGroups: [String: [MediaItem]] = [:]
        
        for item in allMedia {
            if let hash = item.contentHash {
                hashGroups[hash, default: []].append(item)
            }
        }
        
        for (hash, items) in hashGroups where items.count > 1 {
            if !processedHashes.contains(hash) {
                duplicates.append(items)
                processedHashes.insert(hash)
            }
        }
        
        return duplicates.sorted { $0.first!.fileSize > $1.first!.fileSize }
    }
    
    func findLargeFiles(minimumSizeMB: Double = 10.0) -> [MediaItem] {
        let minimumSize = Int64(minimumSizeMB * 1024 * 1024)
        let allMedia = photos + videos
        return allMedia.filter { $0.fileSize >= minimumSize }
            .sorted { $0.fileSize > $1.fileSize }
    }
    
    func findScreenshots() -> [MediaItem] {
        return photos.filter { $0.isScreenshot }
    }
    
    func findSimilarPhotos() -> [[MediaItem]] {
        // Group photos taken within 2 seconds of each other (burst photos)
        var groups: [[MediaItem]] = []
        var sortedPhotos = photos.sorted { $0.creationDate < $1.creationDate }
        
        var currentGroup: [MediaItem] = []
        var lastDate: Date?
        
        for photo in sortedPhotos {
            if let last = lastDate, photo.creationDate.timeIntervalSince(last) <= 2.0 {
                currentGroup.append(photo)
            } else {
                if currentGroup.count > 1 {
                    groups.append(currentGroup)
                }
                currentGroup = [photo]
            }
            lastDate = photo.creationDate
        }
        
        if currentGroup.count > 1 {
            groups.append(currentGroup)
        }
        
        return groups
    }
}

