# PhotoCleaner - Setup Instructions

## Quick Start Guide

### Prerequisites
- Mac with macOS 12.0 or later
- Xcode 13.0 or later
- iOS device or simulator running iOS 15.0+

### Step 1: Create Xcode Project
1. Open Xcode
2. Select "Create a new Xcode project"
3. Choose "iOS" → "App"
4. Configure project:
   - Product Name: `PhotoCleaner`
   - Team: Select your team
   - Organization Identifier: `com.yourcompany`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: None (we'll use PhotoKit)
   - Include Tests: Optional

### Step 2: Add Source Files
1. Delete the default `ContentView.swift` file
2. Create folder structure:
   ```
   PhotoCleaner/
   ├── Models/
   └── Views/
   ```
3. Add files from this repository:
   - Copy `PhotoCleanerApp.swift` to project root
   - Copy `ContentView.swift` to project root
   - Copy files from `Models/` folder
   - Copy files from `Views/` folder

### Step 3: Configure Info.plist
1. Select your project in Xcode navigator
2. Select your app target
3. Go to "Info" tab
4. Add these keys (or merge with provided `Info.plist`):
   - **Privacy - Photo Library Usage Description**
     - Value: `PhotoCleaner needs access to your photo library to help you manage storage by identifying and deleting duplicate photos, large files, and screenshots.`
   - **Privacy - Photo Library Additions Usage Description**
     - Value: `PhotoCleaner may need to save photos to your library.`

### Step 4: Set Deployment Target
1. Select your project
2. Select your target
3. In "General" tab, set **Minimum Deployments** to **iOS 15.0**

### Step 5: Configure Capabilities
1. Select your target
2. Go to "Signing & Capabilities"
3. Select your development team
4. Enable automatic signing

### Step 6: Build and Run
1. Select your target device (simulator or physical device)
2. Press ⌘ + R to build and run
3. Grant photo library access when prompted

## Testing on Physical Device

### Requirements
- iPhone running iOS 15.0 or later
- USB cable
- Apple Developer account (free or paid)

### Steps
1. Connect iPhone to Mac
2. Select your iPhone as the target device
3. If prompted, trust the computer on your iPhone
4. Build and run
5. On first launch, go to Settings → General → Device Management
6. Trust your developer certificate

## Adding Test Photos

Since the app manages real photos, you'll need test data:

1. **Use Simulator Photos**:
   - Drag and drop images into the simulator
   - Go to Photos app to verify

2. **On Physical Device**:
   - Transfer test photos via AirDrop
   - Use iTunes/Finder to sync photos
   - Take screenshots (for screenshot detection)

## Common Issues

### "No module named Photos"
- Ensure you're building for iOS target
- Clean build folder (⌘ + Shift + K)

### Permission Denied
- Check Info.plist has usage descriptions
- Delete and reinstall app
- Reset simulator (Device → Erase All Content)

### Build Errors
- Ensure all files are added to target
- Check Swift version (5.5+)
- Verify deployment target (iOS 15.0+)

## Project Structure in Xcode

```
PhotoCleaner
├── PhotoCleanerApp.swift
├── ContentView.swift
├── Models
│   ├── PhotoManager.swift
│   └── MediaItem.swift
├── Views
│   ├── StorageView.swift
│   ├── MediaBrowserView.swift
│   ├── SmartCleanView.swift
│   └── SettingsView.swift
├── Assets.xcassets
│   └── AppIcon.appiconset
└── Info.plist
```

## Customization

### Changing App Icon
1. Create icon images (1024x1024px)
2. Open `Assets.xcassets` → `AppIcon`
3. Drag icons into appropriate slots
4. Rebuild project

### Changing App Name
1. Select project in navigator
2. Select target
3. Change "Display Name" in General tab

### Changing Bundle Identifier
1. Select project
2. Select target
3. Update "Bundle Identifier" in General tab

## Development Tips

### Live Preview
- Use `#Preview` macro for quick UI testing
- Press ⌘ + Option + P to refresh preview
- Only works in SwiftUI views

### Debugging
- Use breakpoints for debugging
- Print statements: `print("Debug: \(variable)")`
- View debugging: Debug → View Debugging → Capture View Hierarchy

### Performance
- Test with large photo libraries (1000+ photos)
- Monitor memory usage in Xcode
- Use Instruments for profiling

## Next Steps

1. **Test Core Features**:
   - Photo library access
   - Thumbnail loading
   - Deletion functionality

2. **Customize**:
   - Adjust colors and styling
   - Modify duplicate detection
   - Add your own features

3. **Enhance**:
   - Add unit tests
   - Implement analytics
   - Add iCloud backup detection

## Resources

- [Apple PhotoKit Documentation](https://developer.apple.com/documentation/photokit)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [iOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/ios)

## Support

If you encounter issues:
1. Check the troubleshooting section in README.md
2. Ensure all files are properly added to the target
3. Verify Info.plist permissions
4. Clean and rebuild the project

---

Happy coding! 🚀

