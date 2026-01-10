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
                    
                    if trackService.recommendedTracks.isEmpty {
                        VStack(spacing: 16) {
                            if trackService.isLoading {
                                ProgressView("Loading tracks...")
                            } else {
                                Image(systemName: "mountain.2")
                                    .font(.system(size: 60))
                                    .foregroundColor(.secondary)
                                
                                Text("No Recommended Tracks")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                if let errorMessage = trackService.errorMessage {
                                    Text(errorMessage)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(trackService.recommendedTracks) { track in
                                NavigationLink(destination: TrackDetailView(trackId: track.id)) {
                                    RecommendedTrackCard(
                                        track: track,
                                        isFavorite: favoritesManager.isFavorite(trackId: track.id),
                                        onFavoriteToggle: {
                                            favoritesManager.toggleFavorite(track: track)
                                        }
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
