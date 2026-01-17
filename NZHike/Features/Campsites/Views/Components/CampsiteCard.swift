//
//  CampsiteCard.swift
//  NZHike
//
//  Created by wuhao028 on 12/01/2026.
//

import SwiftUI

struct SimpleCampsiteCard: View {
    let campsite: Campsite
    var isFavorite: Bool = false
    var onFavoriteToggle: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(campsite.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let region = campsite.region {
                        Text(region)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 12) {
                    if let onFavoriteToggle = onFavoriteToggle {
                        Button(action: onFavoriteToggle) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .foregroundColor(isFavorite ? .red : .gray)
                                .font(.system(size: 20))
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.top, 4)
                    }
                    
                    StatusBadge(status: campsite.status)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
