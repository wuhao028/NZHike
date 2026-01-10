//
//  TrackDetailView.swift
//  NZHike
//
//  Created by wuhao028 on 09/01/2026.
//

import SwiftUI

struct TrackDetailView: View {
    let trackId: String
    let docId: String?
    
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
                
                if let docId = docId {
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
                                if let fullDescription = detail.description {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Description")
                                            .font(.headline)
                                        Text(fullDescription)
                                            .font(.body)
                                    }
                                    .padding(.horizontal)
                                }
                                
                                VStack(spacing: 12) {
                                    if let difficulty = detail.difficulty {
                                        DetailRow(icon: "exclamationmark.triangle", title: "Difficulty", value: difficulty)
                                    }
                                    
                                    if let duration = detail.duration {
                                        DetailRow(icon: "clock", title: "Duration", value: duration)
                                    }
                                    
                                    if let distance = detail.distance {
                                        DetailRow(icon: "ruler", title: "Distance", value: distance)
                                    }
                                    
                                    if let elevation = detail.elevation {
                                        DetailRow(icon: "arrow.up.and.down", title: "Elevation", value: elevation)
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .padding(.horizontal)
                                
                                if let facilities = detail.facilities, !facilities.isEmpty {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Facilities")
                                            .font(.headline)
                                        
                                        ForEach(facilities, id: \.self) { facility in
                                            HStack {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.green)
                                                Text(facility)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                                
                                if let hazards = detail.hazards, !hazards.isEmpty {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Hazards & Warnings")
                                            .font(.headline)
                                        
                                        ForEach(hazards, id: \.self) { hazard in
                                            HStack(alignment: .top) {
                                                Image(systemName: "exclamationmark.triangle.fill")
                                                    .foregroundColor(.orange)
                                                Text(hazard)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                                
                                if let images = detail.images, !images.isEmpty {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Images")
                                            .font(.headline)
                                        
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(spacing: 12) {
                                                ForEach(images, id: \.self) { imageUrl in
                                                    AsyncImage(url: URL(string: imageUrl)) { image in
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
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                                
                                if let coordinates = detail.coordinates,
                                   let latitude = coordinates.latitude,
                                   let longitude = coordinates.longitude {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Location")
                                            .font(.headline)
                                        
                                        HStack {
                                            Image(systemName: "mappin.circle.fill")
                                                .foregroundColor(.red)
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("Latitude: \(latitude, specifier: "%.6f")")
                                                    .font(.caption)
                                                Text("Longitude: \(longitude, specifier: "%.6f")")
                                                    .font(.caption)
                                            }
                                        }
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
                } else {
                    // Show message if no docId available
                    VStack(spacing: 8) {
                        Image(systemName: "info.circle")
                            .font(.title)
                            .foregroundColor(.blue)
                        
                        Text("No API details available")
                            .font(.headline)
                        
                        Text("This track doesn't have a DOC API ID")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if let docId = docId {
                await docService.fetchTrackDetail(docId: docId)
            }
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
