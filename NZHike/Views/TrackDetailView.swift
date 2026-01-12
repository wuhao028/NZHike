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
            VStack(alignment: .leading, spacing: 0) {
                // Header Image
                if let track = docService.trackDetail {
                    AsyncImage(url: URL(string: track.introductionThumbnail)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure(_):
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .overlay(
                                    Image(systemName: "mountain.2.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(.secondary)
                                )
                        case .empty:
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .overlay(ProgressView())
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(height: 250)
                    .clipped()
                } else if docService.isLoading {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 250)
                        .overlay(ProgressView())
                } else {
                    // Fallback for when we only have basic track info or error
                     Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 250)
                        .overlay(
                            Image(systemName: "mountain.2.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)
                        )
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    // Title and Basic Info
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top) {
                            Text(track?.name ?? "Unknown Track")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Spacer()
                            
                            if let track = track {
                                Button(action: {
                                    favoritesManager.toggleFavorite(track: track)
                                }) {
                                    Image(systemName: favoritesManager.isFavorite(trackId: track.id) ? "heart.fill" : "heart")
                                        .foregroundColor(favoritesManager.isFavorite(trackId: track.id) ? .red : .gray)
                                        .font(.title2)
                                        .padding(8)
                                        .background(Color(.systemGray6))
                                        .clipShape(Circle())
                                }
                            }
                        }
                        
                        if let detail = docService.trackDetail, !detail.region.isEmpty {
                            HStack {
                                Image(systemName: "map")
                                Text(detail.region.joined(separator: ", "))
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        } else if let track = track {
                             HStack {
                                Image(systemName: "map")
                                Text(track.regionString)
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        }
                    }
                    
                    if let detail = docService.trackDetail {
                        // Stats Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            if !detail.distance.isEmpty {
                                StatBox(icon: "ruler", title: "Distance", value: detail.distance)
                            }
                            
                            if !detail.walkDuration.isEmpty {
                                StatBox(icon: "clock", title: "Duration", value: detail.walkDuration)
                            }
                            
                            if !detail.walkTrackCategory.isEmpty {
                                StatBox(icon: "figure.walk", title: "Difficulty", value: detail.walkTrackCategory.first ?? "Unknown")
                            }
                            
                            if let dogs = detail.dogsAllowed.isEmpty ? nil : detail.dogsAllowed {
                                // Shorten description for box if really long, or just use icon
                                StatBox(icon: "pawprint", title: "Dogs", value: dogs.contains("No dogs") ? "No Dogs" : "Check Rules")
                            }
                        }
                        
                        Divider()
                        
                        // Introduction
                        if !detail.introduction.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("About")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                
                                Text(detail.introduction)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        
                        // Activities
                        if !detail.permittedActivities.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Permitted Activities")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                
                                FlowLayout(spacing: 8) {
                                    ForEach(detail.permittedActivities, id: \.self) { activity in
                                        ChipView(text: activity, color: .blue)
                                    }
                                }
                            }
                        }
                        
                        // More Details
                        VStack(alignment: .leading, spacing: 12) {
                            if !detail.dogsAllowed.isEmpty {
                                DetailRow(icon: "pawprint.fill", title: "Dogs Policy", value: detail.dogsAllowed)
                            }
                            
                            if let wheelchair = detail.wheelchairsAndBuggies, !wheelchair.isEmpty {
                                 DetailRow(icon: "figure.roll", title: "Wheelchair Access", value: wheelchair)
                            }
                            
                            if !detail.staticLink.isEmpty, let url = URL(string: detail.staticLink) {
                                Link(destination: url) {
                                    HStack {
                                        Text("View on DOC Website")
                                            .fontWeight(.semibold)
                                        Spacer()
                                        Image(systemName: "arrow.up.right.square")
                                    }
                                    .padding()
                                    .background(Color.green.opacity(0.1))
                                    .foregroundColor(.green)
                                    .cornerRadius(10)
                                }
                            }
                        }
                        
                    } else if let errorMessage = docService.errorMessage {
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.largeTitle)
                                .foregroundColor(.orange)
                            
                            Text("Unable to load details")
                                .font(.headline)
                            
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button("Retry") {
                                Task {
                                    await docService.fetchTrackDetail(assetId: trackId)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    }
                }
                .padding()
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if docService.trackDetail == nil {
                await docService.fetchTrackDetail(assetId: trackId)
            }
        }
    }
}

struct StatBox: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            } icon: {
                Image(systemName: icon)
                    .foregroundColor(.accentColor)
            }
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                // Allow simple HTML tag stripping if needed, or just display
                Text(value.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
