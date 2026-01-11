//
//  RecommendedHutCard.swift
//  NZHike
//
//  Created by wuhao028 on 09/01/2026.
//

import SwiftUI

struct RecommendedHutCard: View {
    let hut: Hut
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .fill(Color.gray.opacity(0.1))
                .frame(height: 150)
                .overlay(
                    Image(systemName: "house.fill")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                )
            
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
