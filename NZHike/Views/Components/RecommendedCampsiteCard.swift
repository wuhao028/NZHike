//
//  RecommendedCampsiteCard.swift
//  NZHike
//
//  Created by wuhao028 on 12/01/2026.
//

import SwiftUI

struct RecommendedCampsiteCard: View {
    let campsite: Campsite
    
    private var imageName: String {
        campsite.name.lowercased()
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
                            Image(systemName: "tent.fill")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                        )
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(campsite.name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                if let region = campsite.region {
                    HStack {
                        Image(systemName: "map")
                        Text(region)
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                
                HStack {
                    StatusBadge(status: campsite.status)
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
