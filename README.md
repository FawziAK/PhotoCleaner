# PhotoCleaner - iPhone Storage Management App

A modern iOS app that helps users free up storage space by intelligently managing photos and videos on their iPhone.

![Platform](https://img.shields.io/badge/platform-iOS%2015.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.5%2B-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-3.0-green)

## Features

### 📊 Storage Analysis
- Real-time storage usage visualization
- Breakdown by media type (photos vs videos)
- Interactive charts and statistics
- Quick overview of total photos and videos

### 🖼️ Media Browser
- Grid view of all photos and videos
- Batch selection and deletion
- Multiple sorting options:
  - Newest/Oldest first
  - Largest/Smallest files
- Quick file size display
- Video duration indicators

### ✨ Smart Cleaning Features

#### 1. Duplicate Detection
- Identifies duplicate photos and videos
- Groups duplicates together
- Shows potential storage savings
- Auto-select feature to keep one copy

#### 2. Large Files Finder
- Finds photos and videos taking up the most space
- Adjustable size threshold (5MB - 100MB)
- Sorted by file size
- Quick preview with detailed information

#### 3. Screenshot Manager
- Automatically detects screenshots
- Bulk selection and deletion
- Helps clean up temporary screenshots

#### 4. Similar Photos
- Identifies burst photos
- Groups photos taken within seconds of each other
- Helps remove near-duplicate shots

### ⚙️ Settings & Preferences
- Photo library access management
- Customizable preferences
- Backup warnings
- Delete confirmations

## Requirements

- iOS 15.0 or later
- iPhone or iPad
- Xcode 13.0+ (for development)
- Swift 5.5+

## Installation

### Option 1: Xcode
1. Clone or download this repository
2. Open the project in Xcode
3. Select your target device or simulator
4. Build and run (⌘ + R)

### Option 2: Manual Setup
1. Create a new iOS App project in Xcode
2. Copy all `.swift` files to your project
3. Copy `Info.plist` configuration
4. Ensure minimum deployment target is iOS 15.0
5. Build and run

## Project Structure

```
PhotoCleaner/
├── PhotoCleanerApp.swift          # App entry point
├── ContentView.swift              # Main tab view
├── Models/
│   ├── PhotoManager.swift         # Photo library manager
│   └── MediaItem.swift            # Media item model
├── Views/
│   ├── StorageView.swift          # Storage analysis view
│   ├── MediaBrowserView.swift     # Photo/video browser
│   ├── SmartCleanView.swift       # Smart cleaning features
│   └── SettingsView.swift         # Settings screen
└── Info.plist                     # App configuration
```

## Privacy & Permissions

This app requires photo library access to function. The app requests:

- **Photo Library Access (Read/Write)**: To view, analyze, and delete photos and videos
- The app never uploads or shares your photos
- All processing happens locally on your device
- No data is collected or transmitted

## Usage Guide

### Getting Started
1. Launch the app
2. Grant photo library access when prompted
3. Wait for the app to analyze your library

### Finding and Deleting Duplicates
1. Go to the "Smart Clean" tab
2. Select "Duplicates"
3. Tap "Auto-Select" to select all duplicates (keeps one copy)
4. Review selections
5. Tap the delete button
6. Confirm deletion

### Managing Large Files
1. Go to "Smart Clean" → "Large Files"
2. Adjust the size threshold using the slider
3. Select files you want to delete
4. Tap delete and confirm

### Browsing and Deleting Media
1. Go to "Browse" tab
2. Switch between Photos and Videos
3. Tap "Select" to enter selection mode
4. Select items to delete
5. Use the toolbar to delete selected items

## Important Notes

⚠️ **Backup Your Photos**: Always ensure your photos are backed up (iCloud Photos, Google Photos, etc.) before using deletion features.

⚠️ **Deletion is Permanent**: Deleted items go to "Recently Deleted" album but will be permanently removed after 30 days.

⚠️ **Duplicate Detection**: The app uses metadata-based duplicate detection. For more accurate detection, consider using image hashing (requires additional implementation).

## Customization

### Adjusting Duplicate Detection
Edit `PhotoManager.swift` → `generateHash()` method to customize how duplicates are identified.

### Changing UI Colors
Modify color schemes in individual view files or create a custom theme.

### Adding New Features
The architecture supports easy addition of new cleaning features in `SmartCleanView.swift`.

## Technical Details

### Technologies Used
- **SwiftUI**: Modern declarative UI framework
- **PhotoKit**: Apple's framework for photo library access
- **Combine**: Reactive programming for state management
- **Photos Framework**: Asset management and deletion

### Key Components

#### PhotoManager
- Centralized photo library manager
- Observable object for reactive updates
- Handles permissions and asset fetching
- Implements smart detection algorithms

#### MediaItem
- Lightweight model for photos and videos
- Caches important metadata
- Provides formatted strings for display

## Performance Considerations

- Lazy loading of thumbnails
- Background processing for heavy operations
- Efficient grid rendering with LazyVGrid
- Optimized duplicate detection algorithms

## Future Enhancements

Potential features for future versions:
- [ ] Advanced image similarity using ML
- [ ] Cloud backup integration
- [ ] Photo organization suggestions
- [ ] Storage trends over time
- [ ] Export/share functionality
- [ ] Face detection for duplicate removal
- [ ] Location-based photo grouping
- [ ] Advanced video editing features

## Troubleshooting

### App crashes on launch
- Ensure iOS deployment target is 15.0+
- Check Info.plist contains required permission keys

### Photos not loading
- Verify photo library permissions are granted
- Check Settings → PhotoCleaner → Photos

### Delete not working
- Ensure "Read and Write" permission is granted
- Check if photo is in a shared album (may have restrictions)

## Contributing

This is a starter project. Feel free to:
- Add new features
- Improve duplicate detection
- Enhance UI/UX
- Fix bugs
- Add tests

## License

This project is provided as-is for educational and personal use.

## Disclaimer

This app permanently deletes photos and videos. Users are responsible for maintaining their own backups. The developers are not responsible for any data loss.

## Support

For issues or questions:
- Check the troubleshooting section
- Review Apple's PhotoKit documentation
- Ensure you're running a supported iOS version

---

**Built with ❤️ using SwiftUI**

