//
//  FavoritesView.swift
//  NZHike
//
//  Created by wuhao028 on 09/01/2026.
//

import SwiftUI

struct FavoritesView: View {
    @StateObject private var favoritesManager = FavoritesManager()
    
    var body: some View {
        NavigationView {
            Group {
                if favoritesManager.favoriteTracks.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text("No Favorites")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Favorite tracks from the home or search page")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(favoritesManager.favoriteTracks) { track in
                                NavigationLink(destination: TrackDetailView(trackId: track.id)) {
                                    TrackCard(
                                        track: track,
                                        isFavorite: true,
                                        onFavoriteToggle: {
                                            favoritesManager.toggleFavorite(track: track)
                                        }
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                favoritesManager.loadFavorites()
            }
        }
    }
}
