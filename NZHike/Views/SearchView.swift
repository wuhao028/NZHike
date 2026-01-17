//
//  SearchView.swift
//  NZHike
//
//  Created by wuhao028 on 09/01/2026.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject var trackService: TrackService
    @EnvironmentObject var hutService: HutService
    @EnvironmentObject var campsiteService: CampsiteService
    @EnvironmentObject var favoritesManager: FavoritesManager
    
    var body: some View {
        SearchContentView(
            trackService: trackService,
            hutService: hutService,
            campsiteService: campsiteService,
            favoritesManager: favoritesManager
        )
    }
}

struct SearchContentView: View {
    @StateObject private var viewModel: SearchViewModel
    
    init(trackService: TrackService, hutService: HutService, campsiteService: CampsiteService, favoritesManager: FavoritesManager) {
        _viewModel = StateObject(wrappedValue: SearchViewModel(
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
                
                SearchBar(text: $viewModel.searchText, placeholder: viewModel.selectedTab == 0 ? "Search tracks..." : (viewModel.selectedTab == 1 ? "Search huts..." : "Search campsites..."))
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                    .background(Color(.systemBackground).opacity(0.8))
                    .background(.ultraThinMaterial)
                
                if viewModel.searchText.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: viewModel.selectedTab == 0 ? "magnifyingglass" : (viewModel.selectedTab == 1 ? "house" : "tent"))
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text(viewModel.selectedTab == 0 ? "Search Tracks" : (viewModel.selectedTab == 1 ? "Search Huts" : "Search Campsites"))
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(viewModel.selectedTab == 0 ? "Enter track name, region, or keywords" : (viewModel.selectedTab == 1 ? "Enter hut name or region" : "Enter campsite name or region"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    if viewModel.selectedTab == 0 {
                        if viewModel.filteredTracks.isEmpty {
                            EmptyStateView()
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(viewModel.filteredTracks) { track in
                                        NavigationLink(destination: TrackDetailView(trackId: track.id)) {
                                            TrackCard(
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
                                .padding()
                            }
                        }
                    } else if viewModel.selectedTab == 1 {
                        if viewModel.filteredHuts.isEmpty {
                            EmptyStateView()
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(viewModel.filteredHuts) { hut in
                                        NavigationLink(destination: HutDetailView(hut: hut)) {
                                            SimpleHutCard(
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
                                .padding()
                            }
                        }
                    } else {
                        if viewModel.filteredCampsites.isEmpty {
                            EmptyStateView()
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(viewModel.filteredCampsites) { campsite in
                                        NavigationLink(destination: CampsiteDetailView(campsite: campsite)) {
                                            SimpleCampsiteCard(
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
                                .padding()
                            }
                        }
                    }
                }
            } // End of VStack
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
