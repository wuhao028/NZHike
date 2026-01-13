//
//  ContentView.swift
//  NZHike
//
//  Created by wuhao028 on 09/01/2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState()
    
    var body: some View {
        ZStack {
            if appState.isDataLoaded {
                MainTabView()
                    .environmentObject(appState)
                    .environmentObject(appState.trackService)
                    .environmentObject(appState.hutService)
                    .environmentObject(appState.campsiteService)
                    .environmentObject(appState.favoritesManager)
                    .transition(.opacity)
            } else {
                LoadingView()
                    .transition(.opacity)
            }
        }
    }
}

#Preview {
    ContentView()
}
