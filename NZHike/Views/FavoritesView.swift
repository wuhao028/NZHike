//
//  FavoritesView.swift
//  NZHike
//
//  Created by wuhao028 on 09/01/2026.
//

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var favoritesManager: FavoritesManager
    @State private var selectedCategory: FavoriteCategory = .all
    
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
                        
                        Text("Favorite items from the home or search page")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    VStack {
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(FavoriteCategory.allCases, id: \.self) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                        
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                // Tracks
                                if shouldShow(.tracks) && !favoritesManager.favoriteTracks.isEmpty {
                                    if selectedCategory == .all {
                                        SectionHeader(title: "Tracks")
                                    }
                                    
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
                                
                                // Huts
                                if shouldShow(.huts) && !favoritesManager.favoriteHuts.isEmpty {
                                    if selectedCategory == .all {
                                        SectionHeader(title: "Huts")
                                    }
                                    
                                    ForEach(favoritesManager.favoriteHuts) { hut in
                                        NavigationLink(destination: HutDetailView(hut: hut)) {
                                            SimpleHutCard(
                                                hut: hut,
                                                isFavorite: true,
                                                onFavoriteToggle: {
                                                    favoritesManager.toggleFavorite(hut: hut)
                                                }
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                
                                // Campsites
                                if shouldShow(.campsites) && !favoritesManager.favoriteCampsites.isEmpty {
                                    if selectedCategory == .all {
                                        SectionHeader(title: "Campsites")
                                    }
                                    
                                    ForEach(favoritesManager.favoriteCampsites) { campsite in
                                        NavigationLink(destination: CampsiteDetailView(campsite: campsite)) {
                                            SimpleCampsiteCard(
                                                campsite: campsite,
                                                isFavorite: true,
                                                onFavoriteToggle: {
                                                    favoritesManager.toggleFavorite(campsite: campsite)
                                                }
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                            .padding()
                        }
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
    
    private func shouldShow(_ category: FavoriteCategory) -> Bool {
        selectedCategory == .all || selectedCategory == category
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.top, 8)
    }
}

enum FavoriteCategory: String, CaseIterable {
    case all = "All"
    case tracks = "Tracks"
    case huts = "Huts"
    case campsites = "Campsites"
}

