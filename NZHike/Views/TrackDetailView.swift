//
//  TrackDetailView.swift
//  NZHike
//
//  Created by wuhao028 on 09/01/2026.
//

import SwiftUI

struct TrackDetailView: View {
    let trackId: String // This is the assetId
    
    @StateObject private var docService = DOCAPIService()
    @StateObject private var favoritesManager = FavoritesManager()
    @StateObject private var trackService = TrackService()
    @Environment(\.dismiss) var dismiss
    
    var track: Track? {
        // First try to find in allTracks, then in recommendedTracks, then in favorites
        trackService.allTracks.first(where: { $0.id == trackId }) ??
        trackService.recommendedTracks.first(where: { $0.id == trackId }) ??
        favoritesManager.favoriteTracks.first(where: { $0.id == trackId })
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let track = track {
                    // 基本信息
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(track.name)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button(action: {
                                favoritesManager.toggleFavorite(track: track)
                            }) {
                                Image(systemName: favoritesManager.isFavorite(trackId: track.id) ? "heart.fill" : "heart")
                                    .foregroundColor(favoritesManager.isFavorite(trackId: track.id) ? .red : .gray)
                                    .font(.title2)
                            }
                        }
                    }
                    .padding()
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    if docService.isLoading {
                        HStack {
                            ProgressView()
                            Text("Loading details from DOC...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    } else if let track = docService.trackDetail {
                        VStack(alignment: .leading, spacing: 16) {
                                        // image
                                        AsyncImage(url: URL(string: track.introductionThumbnail ?? "")) { phase in
                                            switch phase {
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                            case .failure(_):
                                                Color.gray.opacity(0.3)
                                            case .empty:
                                                ProgressView()
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                        .frame(height: 220)
                                        .clipped()


                                        // name
                                        Text(track.name)
                                            .font(.title)
                                            .bold()
                                            .padding(.horizontal)


                                        // info row (distance / duration / difficulty)
                                        VStack(alignment: .leading, spacing: 8) {

                                            if !track.distance.isEmpty {
                                                Label(track.distance, systemImage: "map")
                                            }

                                            if !track.walkDuration.isEmpty {
                                                Label(track.walkDuration, systemImage: "clock")
                                            }

                                            if !track.walkTrackCategory.isEmpty {
                                                Label(track.walkDuration, systemImage: "figure.walk")
                                            }

                                        }
                                        .font(.subheadline)
                                        .padding(.horizontal)


                                        Divider().padding(.horizontal)


                                        // Introduction
                            if !track.introduction.isEmpty {
                                            Text("Introduction")
                                                .font(.headline)
                                                .padding(.horizontal)

                                            Text(track.introduction)
                                                .foregroundColor(.secondary)
                                                .padding(.horizontal)
                                        }

                                        // Activities
                            if !track.permittedActivities.isEmpty {
                                            Text("Permitted Activities")
                                                .font(.headline)
                                                .padding(.horizontal)

                                            ForEach(track.permittedActivities, id: \.self) { act in
                                                Text("• \(act)")
                                                    .padding(.horizontal)
                                            }
                                        }

                                        // Dogs
                            if !track.dogsAllowed.isEmpty {
                                            Text("Dogs")
                                                .font(.headline)
                                                .padding(.horizontal)

                                            Text(track.dogsAllowed)
                                                .foregroundColor(.secondary)
                                                .padding(.horizontal)
                                        }

                                        // Location
                                        if let region = track.region.first {
                                            Text("Location")
                                                .font(.headline)
                                                .padding(.horizontal)

                                            Text(region)
                                                .foregroundColor(.secondary)
                                                .padding(.horizontal)
                                        }

                                        Spacer(minLength: 30)
                                    }
                    } else if let errorMessage = docService.errorMessage {
                        VStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.title)
                                .foregroundColor(.orange)
                            
                            Text("Failed to load API details")
                                .font(.headline)
                            
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // Fetch API details using assetId (trackId)
            await docService.fetchTrackDetail(assetId: trackId)
        }
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}
