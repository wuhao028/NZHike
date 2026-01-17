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
    
    var body: some View {
        HomeContentView(
            trackService: trackService,
            hutService: hutService,
            campsiteService: campsiteService,
            favoritesManager: favoritesManager
        )
    }
}

struct HomeContentView: View {
    @StateObject private var viewModel: HomeViewModel
    
    init(trackService: TrackService, hutService: HutService, campsiteService: CampsiteService, favoritesManager: FavoritesManager) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(
            trackService: trackService,
            hutService: hutService,
            campsiteService: campsiteService,
            favoritesManager: favoritesManager
        ))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Picker("Type", selection: $viewModel.selectedTab) {
                    Text("Tracks").tag(0)
                    Text("Huts").tag(1)
                    Text("Campsites").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                if viewModel.selectedTab == 0 {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            WeatherHeaderView()
                                .padding(.top)
                                .padding(.horizontal)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Recommended Tracks")
                                    .font(.system(.largeTitle, design: .rounded))
                                    .fontWeight(.bold)
                                
                                Text("Explore New Zealand's trails")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                            
                            if viewModel.recommendedTracks.isEmpty {
                                emptyTracksView
                            } else {
                                LazyVStack(spacing: 16) {
                                    ForEach(viewModel.recommendedTracks) { track in
                                        NavigationLink(destination: TrackDetailView(trackId: track.id)) {
                                            RecommendedTrackCard(
                                                track: track,
                                                isFavorite: viewModel.isFavorite(track: track),
                                                onFavoriteToggle: {
                                                    viewModel.toggleFavorite(track: track)
                                                }
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.bottom, 20)
                            }
                        }
                    }
                    .background(Color(.systemGroupedBackground))
                } else if viewModel.selectedTab == 1 {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Recommended Huts")
                                    .font(.system(.largeTitle, design: .rounded))
                                    .fontWeight(.bold)
                                
                                Text("Stay in NZ backcountry huts")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                            
                            if viewModel.recommendedHuts.isEmpty {
                                emptyHutsView
                            } else {
                                LazyVStack(spacing: 16) {
                                    ForEach(viewModel.recommendedHuts) { hut in
                                        NavigationLink(destination: HutDetailView(hut: hut)) {
                                            RecommendedHutCard(
                                                hut: hut,
                                                isFavorite: viewModel.isFavorite(hut: hut),
                                                onFavoriteToggle: {
                                                    viewModel.toggleFavorite(hut: hut)
                                                }
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.bottom, 20)
                            }
                        }
                    }
                    .background(Color(.systemGroupedBackground))
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Recommended Campsites")
                                    .font(.system(.largeTitle, design: .rounded))
                                    .fontWeight(.bold)
                                
                                Text("Discover great camping spots")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                            
                            if viewModel.recommendedCampsites.isEmpty {
                                emptyCampsitesView
                            } else {
                                LazyVStack(spacing: 16) {
                                    ForEach(viewModel.recommendedCampsites) { campsite in
                                        NavigationLink(destination: CampsiteDetailView(campsite: campsite)) {
                                            RecommendedCampsiteCard(
                                                campsite: campsite,
                                                isFavorite: viewModel.isFavorite(campsite: campsite),
                                                onFavoriteToggle: {
                                                    viewModel.toggleFavorite(campsite: campsite)
                                                }
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.bottom, 20)
                            }
                        }
                    }
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var emptyTracksView: some View {
        VStack(spacing: 16) {
            if viewModel.isTracksLoading {
                ProgressView("Loading tracks...")
            } else {
                Image(systemName: "mountain.2")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
                Text("No Recommended Tracks")
                    .font(.title2)
                    .fontWeight(.semibold)
                if let errorMessage = viewModel.tracksErrorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    private var emptyHutsView: some View {
        VStack(spacing: 16) {
            if viewModel.isHutsLoading {
                ProgressView("Loading huts...")
            } else {
                Image(systemName: "house")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
                Text("No Recommended Huts")
                    .font(.title2)
                    .fontWeight(.semibold)
                if let errorMessage = viewModel.hutsErrorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    private var emptyCampsitesView: some View {
        VStack(spacing: 16) {
            if viewModel.isCampsitesLoading {
                ProgressView("Loading campsites...")
            } else {
                Image(systemName: "tent")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
                Text("No Recommended Campsites")
                    .font(.title2)
                    .fontWeight(.semibold)
                if let errorMessage = viewModel.campsitesErrorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}
