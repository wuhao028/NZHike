//
//  FavoritesView.swift
//  NZHike
//
//  Created by wuhao028 on 09/01/2026.
//

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var favoritesManager: FavoritesManager
    
    var body: some View {
        FavoritesContentView(favoritesManager: favoritesManager)
    }
}

struct FavoritesContentView: View {
    @StateObject private var viewModel: FavoritesViewModel
    
    init(favoritesManager: FavoritesManager) {
        _viewModel = StateObject(wrappedValue: FavoritesViewModel(favoritesManager: favoritesManager))
    }
    
    var body: some View {
        NavigationView {
            Group {
                if !viewModel.hasFavorites {
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
                    VStack(spacing: 0) {
                        Picker("Category", selection: $viewModel.selectedCategory) {
                            ForEach(FavoriteCategory.allCases, id: \.self) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color(.systemBackground))
                        
                        if viewModel.showMapView {
                            FavoritesMapView(selectedCategory: $viewModel.selectedCategory)
                                .transition(.opacity)
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 16) {
                                    // Tracks
                                    if viewModel.shouldShow(.tracks) && !viewModel.favoriteTracks.isEmpty {
                                        if viewModel.selectedCategory == .all {
                                            SectionHeader(title: "Tracks")
                                        }
                                        
                                        ForEach(viewModel.favoriteTracks) { track in
                                            NavigationLink(destination: TrackDetailView(trackId: track.id)) {
                                                TrackCard(
                                                    track: track,
                                                    isFavorite: true,
                                                    onFavoriteToggle: {
                                                        viewModel.toggleFavorite(track: track)
                                                    }
                                                )
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                    
                                    // Huts
                                    if viewModel.shouldShow(.huts) && !viewModel.favoriteHuts.isEmpty {
                                        if viewModel.selectedCategory == .all {
                                            SectionHeader(title: "Huts")
                                        }
                                        
                                        ForEach(viewModel.favoriteHuts) { hut in
                                            NavigationLink(destination: HutDetailView(hut: hut)) {
                                                SimpleHutCard(
                                                    hut: hut,
                                                    isFavorite: true,
                                                    onFavoriteToggle: {
                                                        viewModel.toggleFavorite(hut: hut)
                                                    }
                                                )
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                    
                                    // Campsites
                                    if viewModel.shouldShow(.campsites) && !viewModel.favoriteCampsites.isEmpty {
                                        if viewModel.selectedCategory == .all {
                                            SectionHeader(title: "Campsites")
                                        }
                                        
                                        ForEach(viewModel.favoriteCampsites) { campsite in
                                            NavigationLink(destination: CampsiteDetailView(campsite: campsite)) {
                                                SimpleCampsiteCard(
                                                    campsite: campsite,
                                                    isFavorite: true,
                                                    onFavoriteToggle: {
                                                        viewModel.toggleFavorite(campsite: campsite)
                                                    }
                                                )
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                }
                                .padding()
                            }
                            .transition(.opacity)
                        }
                    }
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.hasFavorites {
                        Button(action: {
                            withAnimation(.easeInOut) {
                                viewModel.showMapView.toggle()
                            }
                        }) {
                            Image(systemName: viewModel.showMapView ? "list.bullet" : "map")
                        }
                    }
                }
            }
            .onAppear {
                viewModel.refresh()
            }
        }
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}
