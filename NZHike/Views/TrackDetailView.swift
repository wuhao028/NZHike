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
        trackService.allTracks.first(where: { $0.id == trackId })
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
                                favoritesManager.toggleFavorite(trackId: track.id)
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
                    
                    if docService.isLoading {
                        ProgressView("Loading details...")
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else if let detail = docService.trackDetail {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Details")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            if let fullDescription = detail.description {
                                Text(fullDescription)
                                    .font(.body)
                                    .padding(.horizontal)
                            }
                            
                            if let elevation = detail.elevation {
                                DetailRow(icon: "arrow.up.and.down", title: "Elevation", value: elevation)
                                    .padding(.horizontal)
                            }
                            
                            if let facilities = detail.facilities, !facilities.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Facilities")
                                        .font(.headline)
                                        .padding(.horizontal)
                                    
                                    ForEach(facilities, id: \.self) { facility in
                                        HStack {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                            Text(facility)
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                            
                            if let hazards = detail.hazards, !hazards.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Hazards")
                                        .font(.headline)
                                        .padding(.horizontal)
                                    
                                    ForEach(hazards, id: \.self) { hazard in
                                        HStack {
                                            Image(systemName: "exclamationmark.triangle.fill")
                                                .foregroundColor(.orange)
                                            Text(hazard)
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                            
                            if let coordinates = detail.coordinates {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Location")
                                        .font(.headline)
                                        .padding(.horizontal)
                                    
                                    Text("Latitude: \(coordinates.latitude, specifier: "%.6f")")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal)
                                    
                                    Text("Longitude: \(coordinates.longitude, specifier: "%.6f")")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    } else if let errorMessage = docService.errorMessage {
                        VStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.title)
                                .foregroundColor(.orange)
                            
                            Text("Failed to load details")
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
