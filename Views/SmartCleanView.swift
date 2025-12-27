//
//  SmartCleanView.swift
//  PhotoCleaner
//
//  Smart cleaning features for duplicates, large files, etc.
//

import SwiftUI
import Photos

struct SmartCleanView: View {
    @EnvironmentObject var photoManager: PhotoManager
    @State private var selectedCategory: CleanCategory = .duplicates
    
    enum CleanCategory: String, CaseIterable {
        case duplicates = "Duplicates"
        case largeFiles = "Large Files"
        case screenshots = "Screenshots"
        case similar = "Similar Photos"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Picker("Category", selection: $selectedCategory) {
                    ForEach(CleanCategory.allCases, id: \.self) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                switch selectedCategory {
                case .duplicates:
                    DuplicatesView()
                case .largeFiles:
                    LargeFilesView()
                case .screenshots:
                    ScreenshotsView()
                case .similar:
                    SimilarPhotosView()
                }
            }
            .navigationTitle("Smart Clean")
        }
    }
}

struct DuplicatesView: View {
    @EnvironmentObject var photoManager: PhotoManager
    @State private var duplicateGroups: [[MediaItem]] = []
    @State private var selectedItems: Set<MediaItem> = []
    @State private var showingDeleteConfirmation = false
    @State private var isLoading = true
    
    var potentialSavings: Int64 {
        duplicateGroups.reduce(0) { total, group in
            // Keep one, delete the rest
            let groupSize = group.first?.fileSize ?? 0
            return total + (groupSize * Int64(group.count - 1))
        }
    }
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Analyzing duplicates...")
                    .padding()
            } else if duplicateGroups.isEmpty {
                EmptyStateView(
                    icon: "checkmark.circle.fill",
                    title: "No Duplicates Found",
                    description: "Your library is clean!",
                    color: .green
                )
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        // Summary card
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(duplicateGroups.count) duplicate groups")
                                    .font(.headline)
                                Text("Potential savings: \(ByteCountFormatter.string(fromByteCount: potentialSavings, countStyle: .file))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button("Auto-Select") {
                                autoSelectDuplicates()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        // Duplicate groups
                        ForEach(duplicateGroups.indices, id: \.self) { index in
                            DuplicateGroupView(
                                group: duplicateGroups[index],
                                selectedItems: $selectedItems
                            )
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                    .padding(.bottom, selectedItems.isEmpty ? 0 : 80)
                }
                
                if !selectedItems.isEmpty {
                    SelectionToolbar(
                        selectedCount: selectedItems.count,
                        totalSize: selectedItems.reduce(0) { $0 + $1.fileSize },
                        onDelete: {
                            showingDeleteConfirmation = true
                        },
                        onSelectAll: {
                            // Select all but the first in each group
                            for group in duplicateGroups {
                                selectedItems.formUnion(group.dropFirst())
                            }
                        },
                        onDeselectAll: {
                            selectedItems.removeAll()
                        }
                    )
                }
            }
        }
        .onAppear {
            loadDuplicates()
        }
        .alert("Delete Selected Items?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteSelectedItems()
            }
        } message: {
            Text("Are you sure you want to delete \(selectedItems.count) duplicate(s)?")
        }
    }
    
    func loadDuplicates() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            let duplicates = photoManager.findDuplicates()
            DispatchQueue.main.async {
                self.duplicateGroups = duplicates
                self.isLoading = false
            }
        }
    }
    
    func autoSelectDuplicates() {
        // Automatically select all duplicates except the first one in each group
        selectedItems.removeAll()
        for group in duplicateGroups {
            selectedItems.formUnion(group.dropFirst())
        }
    }
    
    func deleteSelectedItems() {
        let itemsToDelete = Array(selectedItems)
        photoManager.deleteAssets(itemsToDelete) { success, error in
            if success {
                selectedItems.removeAll()
                loadDuplicates()
            }
        }
    }
}

struct DuplicateGroupView: View {
    let group: [MediaItem]
    @Binding var selectedItems: Set<MediaItem>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("\(group.count) copies • \(group.first?.formattedSize ?? "")")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(group) { item in
                        SmallMediaThumbnail(
                            item: item,
                            isSelected: selectedItems.contains(item)
                        )
                        .onTapGesture {
                            if selectedItems.contains(item) {
                                selectedItems.remove(item)
                            } else {
                                selectedItems.insert(item)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct LargeFilesView: View {
    @EnvironmentObject var photoManager: PhotoManager
    @State private var largeFiles: [MediaItem] = []
    @State private var selectedItems: Set<MediaItem> = []
    @State private var showingDeleteConfirmation = false
    @State private var minimumSizeMB: Double = 10.0
    @State private var isLoading = true
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Finding large files...")
                    .padding()
            } else if largeFiles.isEmpty {
                EmptyStateView(
                    icon: "doc.fill",
                    title: "No Large Files",
                    description: "No files larger than \(Int(minimumSizeMB)) MB found",
                    color: .blue
                )
            } else {
                VStack(spacing: 0) {
                    // Filter controls
                    HStack {
                        Text("Minimum size:")
                            .font(.subheadline)
                        Slider(value: $minimumSizeMB, in: 5...100, step: 5)
                        Text("\(Int(minimumSizeMB)) MB")
                            .font(.subheadline)
                            .frame(width: 60)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .onChange(of: minimumSizeMB) { _ in
                        loadLargeFiles()
                    }
                    
                    List {
                        Section {
                            Text("Found \(largeFiles.count) large files")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        ForEach(largeFiles) { item in
                            LargeFileRow(
                                item: item,
                                isSelected: selectedItems.contains(item)
                            )
                            .onTapGesture {
                                if selectedItems.contains(item) {
                                    selectedItems.remove(item)
                                } else {
                                    selectedItems.insert(item)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
                
                if !selectedItems.isEmpty {
                    SelectionToolbar(
                        selectedCount: selectedItems.count,
                        totalSize: selectedItems.reduce(0) { $0 + $1.fileSize },
                        onDelete: {
                            showingDeleteConfirmation = true
                        },
                        onSelectAll: {
                            selectedItems = Set(largeFiles)
                        },
                        onDeselectAll: {
                            selectedItems.removeAll()
                        }
                    )
                }
            }
        }
        .onAppear {
            loadLargeFiles()
        }
        .alert("Delete Selected Items?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteSelectedItems()
            }
        } message: {
            Text("Are you sure you want to delete \(selectedItems.count) large file(s)?")
        }
    }
    
    func loadLargeFiles() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            let files = photoManager.findLargeFiles(minimumSizeMB: minimumSizeMB)
            DispatchQueue.main.async {
                self.largeFiles = files
                self.isLoading = false
            }
        }
    }
    
    func deleteSelectedItems() {
        let itemsToDelete = Array(selectedItems)
        photoManager.deleteAssets(itemsToDelete) { success, error in
            if success {
                selectedItems.removeAll()
                loadLargeFiles()
            }
        }
    }
}

struct ScreenshotsView: View {
    @EnvironmentObject var photoManager: PhotoManager
    @State private var screenshots: [MediaItem] = []
    @State private var selectedItems: Set<MediaItem> = []
    @State private var showingDeleteConfirmation = false
    @State private var isLoading = true
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Finding screenshots...")
                    .padding()
            } else if screenshots.isEmpty {
                EmptyStateView(
                    icon: "camera.viewfinder",
                    title: "No Screenshots",
                    description: "No screenshots found in your library",
                    color: .blue
                )
            } else {
                VStack {
                    HStack {
                        Text("\(screenshots.count) screenshots found")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Button("Select All") {
                            selectedItems = Set(screenshots)
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    
                    MediaGridView(
                        items: screenshots,
                        selectedItems: $selectedItems,
                        isSelectionMode: .constant(true)
                    )
                }
                
                if !selectedItems.isEmpty {
                    SelectionToolbar(
                        selectedCount: selectedItems.count,
                        totalSize: selectedItems.reduce(0) { $0 + $1.fileSize },
                        onDelete: {
                            showingDeleteConfirmation = true
                        },
                        onSelectAll: {
                            selectedItems = Set(screenshots)
                        },
                        onDeselectAll: {
                            selectedItems.removeAll()
                        }
                    )
                }
            }
        }
        .onAppear {
            loadScreenshots()
        }
        .alert("Delete Selected Screenshots?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteSelectedItems()
            }
        } message: {
            Text("Are you sure you want to delete \(selectedItems.count) screenshot(s)?")
        }
    }
    
    func loadScreenshots() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            let items = photoManager.findScreenshots()
            DispatchQueue.main.async {
                self.screenshots = items
                self.isLoading = false
            }
        }
    }
    
    func deleteSelectedItems() {
        let itemsToDelete = Array(selectedItems)
        photoManager.deleteAssets(itemsToDelete) { success, error in
            if success {
                selectedItems.removeAll()
                loadScreenshots()
            }
        }
    }
}

struct SimilarPhotosView: View {
    @EnvironmentObject var photoManager: PhotoManager
    @State private var similarGroups: [[MediaItem]] = []
    @State private var selectedItems: Set<MediaItem> = []
    @State private var showingDeleteConfirmation = false
    @State private var isLoading = true
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Finding similar photos...")
                    .padding()
            } else if similarGroups.isEmpty {
                EmptyStateView(
                    icon: "photo.stack.fill",
                    title: "No Similar Photos",
                    description: "No burst or similar photos found",
                    color: .teal
                )
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("\(similarGroups.count) groups of similar photos")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(similarGroups.indices, id: \.self) { index in
                            DuplicateGroupView(
                                group: similarGroups[index],
                                selectedItems: $selectedItems
                            )
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                    .padding(.bottom, selectedItems.isEmpty ? 0 : 80)
                }
                
                if !selectedItems.isEmpty {
                    SelectionToolbar(
                        selectedCount: selectedItems.count,
                        totalSize: selectedItems.reduce(0) { $0 + $1.fileSize },
                        onDelete: {
                            showingDeleteConfirmation = true
                        },
                        onSelectAll: {
                            for group in similarGroups {
                                selectedItems.formUnion(group.dropFirst())
                            }
                        },
                        onDeselectAll: {
                            selectedItems.removeAll()
                        }
                    )
                }
            }
        }
        .onAppear {
            loadSimilarPhotos()
        }
        .alert("Delete Selected Items?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteSelectedItems()
            }
        } message: {
            Text("Are you sure you want to delete \(selectedItems.count) photo(s)?")
        }
    }
    
    func loadSimilarPhotos() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            let groups = photoManager.findSimilarPhotos()
            DispatchQueue.main.async {
                self.similarGroups = groups
                self.isLoading = false
            }
        }
    }
    
    func deleteSelectedItems() {
        let itemsToDelete = Array(selectedItems)
        photoManager.deleteAssets(itemsToDelete) { success, error in
            if success {
                selectedItems.removeAll()
                loadSimilarPhotos()
            }
        }
    }
}

struct SmallMediaThumbnail: View {
    let item: MediaItem
    let isSelected: Bool
    @State private var thumbnail: UIImage?
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let thumbnail = thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                    .frame(width: 100, height: 100)
                    .overlay {
                        ProgressView()
                    }
            }
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
                    .background(Circle().fill(Color.white))
                    .padding(4)
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        }
        .onAppear {
            loadThumbnail()
        }
    }
    
    func loadThumbnail() {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        
        manager.requestImage(
            for: item.asset,
            targetSize: CGSize(width: 200, height: 200),
            contentMode: .aspectFill,
            options: options
        ) { image, _ in
            self.thumbnail = image
        }
    }
}

struct LargeFileRow: View {
    let item: MediaItem
    let isSelected: Bool
    @State private var thumbnail: UIImage?
    
    var body: some View {
        HStack(spacing: 12) {
            if let thumbnail = thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                    .frame(width: 60, height: 60)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.formattedSize)
                    .font(.headline)
                    .foregroundColor(isSelected ? .blue : .primary)
                
                Text(item.mediaType == .video ? "Video" : "Photo")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(item.resolution)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
        .onAppear {
            loadThumbnail()
        }
    }
    
    func loadThumbnail() {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        
        manager.requestImage(
            for: item.asset,
            targetSize: CGSize(width: 120, height: 120),
            contentMode: .aspectFill,
            options: options
        ) { image, _ in
            self.thumbnail = image
        }
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(color)
            
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SmartCleanView()
        .environmentObject(PhotoManager())
}

