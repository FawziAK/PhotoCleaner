//
//  SettingsView.swift
//  PhotoCleaner
//
//  App settings and information
//

import SwiftUI
import Photos

struct SettingsView: View {
    @EnvironmentObject var photoManager: PhotoManager
    @AppStorage("autoBackupWarning") private var autoBackupWarning = true
    @AppStorage("confirmBeforeDelete") private var confirmBeforeDelete = true
    @AppStorage("showFileSizes") private var showFileSizes = true
    
    var body: some View {
        NavigationView {
            Form {
                Section("Library") {
                    HStack {
                        Text("Authorization Status")
                        Spacer()
                        Text(statusText)
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Refresh Library") {
                        photoManager.loadAllMedia()
                    }
                }
                
                Section("Preferences") {
                    Toggle("Show File Sizes", isOn: $showFileSizes)
                    Toggle("Confirm Before Delete", isOn: $confirmBeforeDelete)
                    Toggle("Backup Warning", isOn: $autoBackupWarning)
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                    Link("Terms of Service", destination: URL(string: "https://example.com/terms")!)
                }
                
                Section {
                    Button(role: .destructive) {
                        // Clear cache if implemented
                    } label: {
                        Text("Clear Cache")
                    }
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("About PhotoCleaner")
                            .font(.headline)
                        
                        Text("PhotoCleaner helps you manage your iPhone storage by identifying and removing duplicate photos, large files, screenshots, and similar images.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("⚠️ Important: Always ensure your photos are backed up (iCloud, Google Photos, etc.) before deleting them.")
                            .font(.caption)
                            .foregroundColor(.orange)
                            .padding(.top, 5)
                    }
                    .padding(.vertical, 5)
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    var statusText: String {
        switch photoManager.authorizationStatus {
        case .authorized:
            return "Full Access"
        case .limited:
            return "Limited Access"
        case .denied, .restricted:
            return "No Access"
        case .notDetermined:
            return "Not Determined"
        @unknown default:
            return "Unknown"
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(PhotoManager())
}

