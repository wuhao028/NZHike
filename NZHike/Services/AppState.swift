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
    
    @Published var isDataLoaded = false
    
    init() {
        checkLoadingStatus()
    }
    
    func checkLoadingStatus() {
        // We wait a bit or check if services are actually finished loading JSON
        // Since loadHuts and loadCampsites are synchronous in init, 
        // they might be done by the time this is called, but let's be sure.
        
        Task {
            // Small delay to ensure the UI has time to show the loading screen 
            // and everything is properly initialized.
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            
            withAnimation(.easeInOut(duration: 0.5)) {
                isDataLoaded = true
            }
        }
    }
}
