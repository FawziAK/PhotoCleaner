//
//  ContentView.swift
//  PhotoCleaner
//
//  Main view with tabs for different features
//

import SwiftUI
import Photos

struct ContentView: View {
    @StateObject private var photoManager = PhotoManager()
    
    var body: some View {
        TabView {
            StorageView()
                .environmentObject(photoManager)
                .tabItem {
                    Label("Storage", systemImage: "chart.pie.fill")
                }
            
            MediaBrowserView()
                .environmentObject(photoManager)
                .tabItem {
                    Label("Browse", systemImage: "photo.on.rectangle")
                }
            
            SmartCleanView()
                .environmentObject(photoManager)
                .tabItem {
                    Label("Smart Clean", systemImage: "sparkles")
                }
            
            SettingsView()
                .environmentObject(photoManager)
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .onAppear {
            photoManager.requestPhotoLibraryAccess()
        }
    }
}

#Preview {
    ContentView()
}

