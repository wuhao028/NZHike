//
//  TrackDetailView.swift
//  NZHike
//
//  Created by wuhao028 on 09/01/2026.
//

import SwiftUI

struct TrackDetailView: View {
    @EnvironmentObject var apiService: DOCAPIService
    @EnvironmentObject var trackService: TrackService
    @EnvironmentObject var favoritesManager: FavoritesManager
    
    let trackId: String
    
    var body: some View {
        TrackDetailContentView(
            trackId: trackId,
            apiService: apiService,
            trackService: trackService,
            favoritesManager: favoritesManager
        )
    }
}

struct TrackDetailContentView: View {
    @StateObject private var viewModel: TrackDetailViewModel
    @Environment(\.dismiss) var dismiss
    
    init(trackId: String, apiService: DOCAPIService, trackService: TrackService, favoritesManager: FavoritesManager) {
        _viewModel = StateObject(wrappedValue: TrackDetailViewModel(
            trackId: trackId,
            apiService: apiService,
            trackService: trackService,
            favoritesManager: favoritesManager
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header Image
                ZStack(alignment: .top) {
                    if let imageUrl = viewModel.trackDetail?.introductionThumbnail, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 250)
                                .clipped()
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 250)
                        }
                    } else if let track = viewModel.track {
                        Image(getImageName(for: track.name))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 250)
                            .clipped()
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 250)
                    }
                    
                    // Top Bar
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .padding(12)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        Button(action: { viewModel.toggleFavorite() }) {
                            Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                                .font(.system(size: 18, weight: .semibold))
                                .padding(12)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                .foregroundColor(viewModel.isFavorite ? .red : .primary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 50) // Manual top padding for safe area since we use ignoresSafeArea
                }
                
                if viewModel.isLoading {
                    ProgressView("Loading details...")
                        .frame(maxWidth: .infinity, minHeight: 200)
                } else if let detail = viewModel.trackDetail {
                    VStack(alignment: .leading, spacing: 16) {
                        // Title and Info
                        VStack(alignment: .leading, spacing: 8) {
                            Text(detail.name)
                                .font(.system(.title, design: .rounded))
                                .fontWeight(.bold)
                            
                            HStack(spacing: 12) {
                                Label(detail.walkDuration, systemImage: "clock")
                                Label(detail.distance, systemImage: "figure.walk")
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        
                        Divider()
                            .padding(.horizontal)
                        
                        // Introduction
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Introduction")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Text(detail.introduction.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression))
                                .font(.body)
                                .foregroundColor(.primary)
                                .lineSpacing(4)
                        }
                        .padding(.horizontal)
                        
                        Divider()
                            .padding(.horizontal)
                        
                        // Location
                        if let x = viewModel.mapX, let y = viewModel.mapY {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Location")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                
                                LocationMapView(easting: x, northing: y, title: viewModel.mapTitle)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Coordinates (NZTM)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("E: \(Int(x)) N: \(Int(y))")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal)
                            
                            Divider()
                                .padding(.horizontal)
                        }
                        
                        // Activities
                        if !detail.permittedActivities.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Permitted Activities")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                
                                FlowLayout(spacing: 8) {
                                    ForEach(detail.permittedActivities, id: \.self) { activity in
                                        Text(activity)
                                            .font(.caption)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(Color.green.opacity(0.1))
                                            .foregroundColor(.green)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text(errorMessage)
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            Task {
                                await viewModel.fetchDetails()
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .task {
            await viewModel.fetchDetails()
        }
    }
    
    private func getImageName(for trackName: String) -> String {
        let name = trackName.lowercased()
        if name.contains("tongariro") { return "tongariro" }
        if name.contains("milford") { return "milford" }
        if name.contains("routeburn") { return "routeburn" }
        if name.contains("abel") { return "abel_tasman" }
        if name.contains("kepler") { return "kepler" }
        if name.contains("rakiura") { return "rakiura" }
        return "track_placeholder"
    }
}
