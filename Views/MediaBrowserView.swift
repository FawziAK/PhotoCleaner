//
//  MediaBrowserView.swift
//  PhotoCleaner
//
//  Browse and manage photos and videos
//

import SwiftUI
import Photos

struct MediaBrowserView: View {
    @EnvironmentObject var photoManager: PhotoManager
    @State private var selectedTab = 0
    @State private var selectedItems: Set<MediaItem> = []
    @State private var isSelectionMode = false
    @State private var showingDeleteConfirmation = false
    @State private var sortOption: SortOption = .dateDescending
    
    enum SortOption: String, CaseIterable {
        case dateDescending = "Newest First"
        case dateAscending = "Oldest First"
        case sizeDescending = "Largest First"
        case sizeAscending = "Smallest First"
    }
    
    var sortedPhotos: [MediaItem] {
        switch sortOption {
        case .dateDescending:
            return photoManager.photos.sorted { $0.creationDate > $1.creationDate }
        case .dateAscending:
            return photoManager.photos.sorted { $0.creationDate < $1.creationDate }
        case .sizeDescending:
            return photoManager.photos.sorted { $0.fileSize > $1.fileSize }
        case .sizeAscending:
            return photoManager.photos.sorted { $0.fileSize < $1.fileSize }
        }
    }
    
    var sortedVideos: [MediaItem] {
        switch sortOption {
        case .dateDescending:
            return photoManager.videos.sorted { $0.creationDate > $1.creationDate }
        case .dateAscending:
            return photoManager.videos.sorted { $0.creationDate < $1.creationDate }
        case .sizeDescending:
            return photoManager.videos.sorted { $0.fileSize > $1.fileSize }
        case .sizeAscending:
            return photoManager.videos.sorted { $0.fileSize < $1.fileSize }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Picker("Media Type", selection: $selectedTab) {
                    Text("Photos (\(photoManager.totalPhotos))").tag(0)
                    Text("Videos (\(photoManager.totalVideos))").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                if selectedTab == 0 {
                    MediaGridView(
                        items: sortedPhotos,
                        selectedItems: $selectedItems,
                        isSelectionMode: $isSelectionMode
                    )
                } else {
                    MediaGridView(
                        items: sortedVideos,
                        selectedItems: $selectedItems,
                        isSelectionMode: $isSelectionMode
                    )
                }
            }
            .navigationTitle("Media Library")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Picker("Sort By", selection: $sortOption) {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isSelectionMode ? "Cancel" : "Select") {
                        isSelectionMode.toggle()
                        if !isSelectionMode {
                            selectedItems.removeAll()
                        }
                    }
                }
            }
            .overlay(alignment: .bottom) {
                if isSelectionMode && !selectedItems.isEmpty {
                    SelectionToolbar(
                        selectedCount: selectedItems.count,
                        totalSize: selectedItems.reduce(0) { $0 + $1.fileSize },
                        onDelete: {
                            showingDeleteConfirmation = true
                        },
                        onSelectAll: {
                            let currentItems = selectedTab == 0 ? sortedPhotos : sortedVideos
                            selectedItems = Set(currentItems)
                        },
                        onDeselectAll: {
                            selectedItems.removeAll()
                        }
                    )
                }
            }
            .alert("Delete Selected Items?", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteSelectedItems()
                }
            } message: {
                Text("Are you sure you want to delete \(selectedItems.count) item(s)? This action cannot be undone.")
            }
        }
    }
    
    func deleteSelectedItems() {
        let itemsToDelete = Array(selectedItems)
        photoManager.deleteAssets(itemsToDelete) { success, error in
            if success {
                selectedItems.removeAll()
                isSelectionMode = false
            }
        }
    }
}

struct MediaGridView: View {
    let items: [MediaItem]
    @Binding var selectedItems: Set<MediaItem>
    @Binding var isSelectionMode: Bool
    
    let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(items) { item in
                    MediaThumbnailView(
                        item: item,
                        isSelected: selectedItems.contains(item),
                        isSelectionMode: isSelectionMode
                    )
                    .onTapGesture {
                        if isSelectionMode {
                            if selectedItems.contains(item) {
                                selectedItems.remove(item)
                            } else {
                                selectedItems.insert(item)
                            }
                        }
                    }
                }
            }
            .padding(.bottom, 80)
        }
    }
}

struct MediaThumbnailView: View {
    let item: MediaItem
    let isSelected: Bool
    let isSelectionMode: Bool
    @State private var thumbnail: UIImage?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topTrailing) {
                if let thumbnail = thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.width)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .overlay {
                            ProgressView()
                        }
                }
                
                // Video duration indicator
                if item.mediaType == .video {
                    HStack {
                        Image(systemName: "play.fill")
                            .font(.caption2)
                        Text(item.formattedDuration)
                            .font(.caption2)
                    }
                    .padding(4)
                    .background(.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(4)
                    .padding(4)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                }
                
                // File size
                Text(item.formattedSize)
                    .font(.caption2)
                    .padding(4)
                    .background(.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(4)
                    .padding(4)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                
                // Selection indicator
                if isSelectionMode {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundColor(isSelected ? .blue : .white)
                        .padding(8)
                        .background(isSelected ? Color.white : Color.black.opacity(0.3))
                        .clipShape(Circle())
                        .padding(4)
                }
            }
            .onAppear {
                loadThumbnail()
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .overlay {
            if isSelected && isSelectionMode {
                Rectangle()
                    .strokeBorder(Color.blue, lineWidth: 3)
            }
        }
    }
    
    func loadThumbnail() {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        
        let targetSize = CGSize(width: 300, height: 300)
        
        manager.requestImage(
            for: item.asset,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: options
        ) { image, _ in
            self.thumbnail = image
        }
    }
}

struct SelectionToolbar: View {
    let selectedCount: Int
    let totalSize: Int64
    let onDelete: () -> Void
    let onSelectAll: () -> Void
    let onDeselectAll: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(selectedCount) selected")
                        .font(.headline)
                    Text(ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("Select All") {
                    onSelectAll()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                
                Button("Deselect") {
                    onDeselectAll()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.red)
                        .clipShape(Circle())
                }
            }
            .padding()
            .background(.ultraThinMaterial)
        }
    }
}

#Preview {
    MediaBrowserView()
        .environmentObject(PhotoManager())
}

