//
//  HomeView.swift
//  NZHike
//
//  Created by wuhao028 on 09/01/2026.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var trackService = TrackService()
    @StateObject private var favoritesManager = FavoritesManager()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Recommended Tracks")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Explore New Zealand's most beautiful hiking trails")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    LazyVStack(spacing: 16) {
                        ForEach(trackService.recommendedTracks) { track in
                            NavigationLink(destination: TrackDetailView(trackId: track.id, docId: track.docId)) {
                                RecommendedTrackCard(
                                    track: track,
                                    isFavorite: favoritesManager.isFavorite(trackId: track.id),
                                    onFavoriteToggle: {
                                        favoritesManager.toggleFavorite(trackId: track.id)
                                    }
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
