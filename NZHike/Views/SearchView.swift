//
//  SearchView.swift
//  NZHike
//
//  Created by wuhao028 on 09/01/2026.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var trackService = TrackService()
    @StateObject private var hutService = HutService()
    @StateObject private var favoritesManager = FavoritesManager()
    @State private var searchText = ""
    @State private var selectedTab = 0
    
    var filteredTracks: [Track] {
        trackService.searchTracks(query: searchText)
    }
    
    var filteredHuts: [Hut] {
        hutService.searchHuts(query: searchText)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Picker("Type", selection: $selectedTab) {
                    Text("Tracks").tag(0)
                    Text("Huts").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                SearchBar(text: $searchText, placeholder: selectedTab == 0 ? "Search tracks..." : "Search huts...")
                    .padding(.horizontal)
                
                if searchText.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: selectedTab == 0 ? "magnifyingglass" : "house")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text(selectedTab == 0 ? "Search Tracks" : "Search Huts")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(selectedTab == 0 ? "Enter track name, region, or keywords" : "Enter hut name or region")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    if selectedTab == 0 {
                        if filteredTracks.isEmpty {
                            EmptyStateView()
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(filteredTracks) { track in
                                        NavigationLink(destination: TrackDetailView(trackId: track.id)) {
                                            TrackCard(
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
                                .padding()
                            }
                        }
                    } else {
                        if filteredHuts.isEmpty {
                            EmptyStateView()
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(filteredHuts) { hut in
                                        NavigationLink(destination: HutDetailView(hut: hut)) {
                                            SimpleHutCard(hut: hut)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Results Found")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Try using different keywords")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search tracks..."
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}
