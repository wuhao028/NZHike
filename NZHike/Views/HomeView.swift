//
//  HomeView.swift
//  NZHike
//
//  Created by wuhao028 on 09/01/2026.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var trackService: TrackService
    @EnvironmentObject var hutService: HutService
    @EnvironmentObject var campsiteService: CampsiteService
    @EnvironmentObject var favoritesManager: FavoritesManager
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Picker("Type", selection: $selectedTab) {
                    Text("Tracks").tag(0)
                    Text("Huts").tag(1)
                    Text("Campsites").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                if selectedTab == 0 {
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
                } else if selectedTab == 1 {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Recommended Huts")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                
                                Text("Stay in New Zealand's iconic backcountry huts")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                            .padding(.top)
                            
                            if hutService.recommendedHuts.isEmpty {
                                VStack(spacing: 16) {
                                    if hutService.isLoading {
                                        ProgressView("Loading huts...")
                                    } else {
                                        Image(systemName: "house")
                                            .font(.system(size: 60))
                                            .foregroundColor(.secondary)
                                        
                                        Text("No Recommended Huts")
                                            .font(.title2)
                                            .fontWeight(.semibold)
                                        
                                        if let errorMessage = hutService.errorMessage {
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
                                    ForEach(hutService.recommendedHuts) { hut in
                                        NavigationLink(destination: HutDetailView(hut: hut)) {
                                            RecommendedHutCard(
                                                hut: hut,
                                                isFavorite: favoritesManager.isFavorite(hutId: hut.id),
                                                onFavoriteToggle: {
                                                    favoritesManager.toggleFavorite(hut: hut)
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
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Recommended Campsites")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                
                                Text("Discover great camping spots")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                            .padding(.top)
                            
                            if campsiteService.recommendedCampsites.isEmpty {
                                VStack(spacing: 16) {
                                    if campsiteService.isLoading {
                                        ProgressView("Loading campsites...")
                                    } else {
                                        Image(systemName: "tent")
                                            .font(.system(size: 60))
                                            .foregroundColor(.secondary)
                                        
                                        Text("No Recommended Campsites")
                                            .font(.title2)
                                            .fontWeight(.semibold)
                                        
                                        if let errorMessage = campsiteService.errorMessage {
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
                                    ForEach(campsiteService.recommendedCampsites) { campsite in
                                        NavigationLink(destination: CampsiteDetailView(campsite: campsite)) {
                                            RecommendedCampsiteCard(
                                                campsite: campsite,
                                                isFavorite: favoritesManager.isFavorite(campsiteId: campsite.id),
                                                onFavoriteToggle: {
                                                    favoritesManager.toggleFavorite(campsite: campsite)
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
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                favoritesManager.loadFavorites()
            }
        }
    }
}


