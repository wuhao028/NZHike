//
//  TrackCard.swift
//  NZHike
//
//  Created by wuhao028 on 09/01/2026.
//

import SwiftUI

struct TrackCard: View {
    let track: Track
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(track.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if !track.region.isEmpty {
                        Text(track.regionString)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button(action: onFavoriteToggle) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(isFavorite ? .red : .gray)
                }
            }
            
            if let description = track.description {
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack(spacing: 16) {
                if let difficulty = track.difficulty {
                    Label(difficulty, systemImage: "exclamationmark.triangle")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let duration = track.duration {
                    Label(duration, systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let distance = track.distance {
                    Label(distance, systemImage: "ruler")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct RecommendedTrackCard: View {
    let track: Track
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void
    
    private var imageName: String {
        // Try to find image by track name (lowercased, spaces replaced with underscores)
        // Handle special cases for known track names
        let trackNameLower = track.name.lowercased()
        
        // Map known track names to their image names
        let imageNameMap: [String: String] = [
            "tongariro alpine crossing": "tongariro",
            "milford track": "milford",
            "routeburn track": "routeburn",
            "abel tasman coast track": "abel_tasman",
            "kepler track": "kepler",
            "rakiura track": "rakiura",
            "heaphy track": "heaphy",
            "paparoa track": "paparoa",
            "lake waikaremoana track": "waikaremoana",
            "whanganui journey": "whanganui",
            "queen charlotte track": "queen_charlotte",
            "mount taranaki summit track": "taranaki"
        ]
        
        if let mappedName = imageNameMap[trackNameLower] {
            return mappedName
        }
        
        // Fallback: generate from track name
        return trackNameLower
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "&", with: "and")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                Group {
                    if let image = UIImage(named: imageName) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        ZStack {
                            Color.gray.opacity(0.3)
                            Image(systemName: "photo")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                        }
                    }
                }
                .frame(height: 200)
                .clipped()
                
                Button(action: onFavoriteToggle) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
                .padding(12)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(track.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if !track.region.isEmpty {
                    Text(track.regionString)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if let description = track.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack(spacing: 16) {
                    if let difficulty = track.difficulty {
                        Label(difficulty, systemImage: "exclamationmark.triangle")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let duration = track.duration {
                        Label(duration, systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let distance = track.distance {
                        Label(distance, systemImage: "ruler")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
