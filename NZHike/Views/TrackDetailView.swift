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
                        
                        if !track.region.isEmpty {
                            Text(track.regionString)
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                        
                        if let description = track.description {
                            Text(description)
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                        
                        VStack(spacing: 12) {
                            if let difficulty = track.difficulty {
                                DetailRow(icon: "exclamationmark.triangle", title: "Difficulty", value: difficulty)
                            }
                            
                            if let duration = track.duration {
                                DetailRow(icon: "clock", title: "Duration", value: duration)
                            }
                            
                            if let distance = track.distance {
                                DetailRow(icon: "ruler", title: "Distance", value: distance)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .padding()
                }
                
                // Always try to fetch API details using assetId
                Divider()
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("API Details")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    if docService.isLoading {
                        HStack {
                            ProgressView()
                            Text("Loading details from DOC API...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    } else if let detail = docService.trackDetail {
                        VStack(alignment: .leading, spacing: 16) {
                            if !detail.introduction.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Description")
                                        .font(.headline)
                                    Text(detail.introduction)
                                        .font(.body)
                                }
                                .padding(.horizontal)
                            }
                            
                            VStack(spacing: 12) {
                                if !detail.distance.isEmpty {
                                    DetailRow(icon: "exclamationmark.triangle", title: "Difficulty", value: detail.distance)
                                }
                                
                                if let duration = detail.mtbDuration {
                                    DetailRow(icon: "clock", title: "Duration", value: duration)
                                }
                                
                                if !detail.distance.isEmpty {
                                    DetailRow(icon: "ruler", title: "Distance", value: detail.distance)
                                }
                                
                                if !detail.walkDuration.isEmpty {
                                    DetailRow(icon: "arrow.up.and.down", title: "Elevation", value: detail.walkDuration)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .padding(.horizontal)
                            
                            if !detail.introductionThumbnail.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Image")
                                        .font(.headline)
                                    
                                    AsyncImage(url: URL(string: detail.introductionThumbnail)) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 200, height: 150)
                                    .cornerRadius(8)
                                    .clipped()
                                }
                                .padding(.horizontal)
                            }
                            
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
