//
//  AppState.swift
//  NZHike
//
//  Created by Antigravity on 13/01/2026.
//

import SwiftUI

@MainActor
class AppState: ObservableObject {
    @Published var trackService = TrackService()
    @Published var hutService = HutService()
    @Published var campsiteService = CampsiteService()
    @Published var favoritesManager = FavoritesManager()
    @Published var apiService = DOCAPIService()
    
    @Published var isDataLoaded = false
    @Published var currentTheme: AppTheme = AppTheme(rawValue: UserDefaults.standard.string(forKey: "appTheme") ?? "system") ?? .system
    
    enum AppTheme: String, CaseIterable {
        case system = "system"
        case light = "light"
        case dark = "dark"
        
        var colorScheme: ColorScheme? {
            switch self {
            case .system: return nil
            case .light: return .light
            case .dark: return .dark
            }
        }
    }
    
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
        UserDefaults.standard.set(theme.rawValue, forKey: "appTheme")
    }
    
    init() {
        checkLoadingStatus()
    }
    
    func checkLoadingStatus() {
        Task {
            // Wait for services to finish loading
            while trackService.isLoading || hutService.isLoading || campsiteService.isLoading {
                try? await Task.sleep(nanoseconds: 100_000_000) // Check every 0.1s
            }
            
            withAnimation(.easeInOut(duration: 0.5)) {
                isDataLoaded = true
            }
        }
    }
}
