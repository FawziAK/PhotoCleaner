//
//  StorageView.swift
//  PhotoCleaner
//
//  Storage analysis and overview
//

import SwiftUI
import Charts
import Photos

struct StorageView: View {
    @EnvironmentObject var photoManager: PhotoManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if photoManager.authorizationStatus != .authorized && 
                       photoManager.authorizationStatus != .limited {
                        permissionView
                    } else if photoManager.isLoading {
                        loadingView
                    } else {
                        storageOverview
                        storageChart
                        quickActions
                    }
                }
                .padding()
            }
            .navigationTitle("Storage Analysis")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        photoManager.loadAllMedia()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }
    
    var permissionView: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Photo Access Required")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("To help you manage your storage, we need access to your photo library.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button(action: {
                photoManager.requestPhotoLibraryAccess()
            }) {
                Text("Grant Access")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
    }
    
    var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Analyzing your library...")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
    
    var storageOverview: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Total Storage Used")
                    .font(.headline)
                Spacer()
            }
            
            Text(ByteCountFormatter.string(fromByteCount: photoManager.totalSize, countStyle: .file))
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.blue)
            
            HStack(spacing: 30) {
                StatBox(
                    icon: "photo.fill",
                    title: "Photos",
                    value: "\(photoManager.totalPhotos)",
                    color: .green
                )
                
                StatBox(
                    icon: "video.fill",
                    title: "Videos",
                    value: "\(photoManager.totalVideos)",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    var storageChart: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Storage Breakdown")
                .font(.headline)
            
            let photoSize = photoManager.photos.reduce(0) { $0 + $1.fileSize }
            let videoSize = photoManager.videos.reduce(0) { $0 + $1.fileSize }
            
            VStack(spacing: 12) {
                StorageBar(
                    label: "Photos",
                    size: photoSize,
                    total: photoManager.totalSize,
                    color: .green
                )
                
                StorageBar(
                    label: "Videos",
                    size: videoSize,
                    total: photoManager.totalSize,
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    var quickActions: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick Actions")
                .font(.headline)
            
            VStack(spacing: 12) {
                QuickActionButton(
                    icon: "doc.on.doc.fill",
                    title: "Find Duplicates",
                    description: "Identify duplicate photos and videos",
                    color: .orange
                )
                
                QuickActionButton(
                    icon: "arrow.up.doc.fill",
                    title: "Large Files",
                    description: "Find files taking up the most space",
                    color: .red
                )
                
                QuickActionButton(
                    icon: "camera.viewfinder",
                    title: "Screenshots",
                    description: "Clean up old screenshots",
                    color: .blue
                )
                
                QuickActionButton(
                    icon: "photo.stack.fill",
                    title: "Similar Photos",
                    description: "Find burst and similar photos",
                    color: .teal
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct StatBox: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct StorageBar: View {
    let label: String
    let size: Int64
    let total: Int64
    let color: Color
    
    var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(size) / Double(total)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(label)
                    .font(.subheadline)
                Spacer()
                Text(ByteCountFormatter.string(fromByteCount: size, countStyle: .file))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text("(\(Int(percentage * 100))%)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * percentage)
                }
            }
            .frame(height: 8)
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    StorageView()
        .environmentObject(PhotoManager())
}

