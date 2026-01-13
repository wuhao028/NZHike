//
//  RecommendedHutCard.swift
//  NZHike
//
//  Created by wuhao028 on 09/01/2026.
//

import SwiftUI

struct RecommendedHutCard: View {
    let hut: Hut
    var isFavorite: Bool = false
    var onFavoriteToggle: (() -> Void)? = nil
    
    private var imageName: String {
        // Simple mapping or lowercased name
        // Huts don't have "image_name" property in JSON yet, so derive from name
        hut.name.lowercased()
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "'", with: "")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                if let image = UIImage(named: imageName) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 150)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 150)
                        .overlay(
                            Image(systemName: "house.fill")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                        )
                }
                
                if let onFavoriteToggle = onFavoriteToggle {
                    Button(action: onFavoriteToggle) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(isFavorite ? .red : .white)
                            .font(.system(size: 18))
                            .padding(8)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(8)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(hut.name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                if let region = hut.region {
                    HStack {
                        Image(systemName: "map")
                        Text(region)
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                
                HStack {
                    StatusBadge(status: hut.status)
                    Spacer()
                }
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
