//
//  HutDetailView.swift
//  NZHike
//
//  Created by wuhao028 on 09/01/2026.
//

import SwiftUI

struct HutDetailView: View {
    let hut: Hut
    @StateObject private var apiService = DOCAPIService()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Image Placeholder
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 200)
                    .overlay(
                        Image(systemName: "house.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                    )
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(hut.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    if let region = hut.region {
                        HStack {
                            Image(systemName: "map")
                            Text(region)
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        StatusBadge(status: hut.status)
                        Spacer()
                    }
                    
                    if apiService.isLoading {
                        ProgressView("Loading details...")
                    } else if let detail = apiService.hutDetail {
                        Divider()
                        
                        if let intro = detail.introduction {
                            Text("About")
                                .font(.headline)
                            Text(intro)
                                .font(.body)
                        }
                        
                        if let bunks = detail.numberOfBunks {
                            HStack {
                                Image(systemName: "bed.double.fill")
                                Text("\(bunks) Bunks")
                            }
                            .font(.subheadline)
                        }
                        
                        if let facilities = detail.facilities, !facilities.isEmpty {
                            Text("Facilities")
                                .font(.headline)
                                .padding(.top, 4)
                            
                            ForEach(facilities, id: \.self) { facility in
                                Text("• \(facility)")
                                    .font(.subheadline)
                            }
                        }
                    } else if let error = apiService.errorMessage {
                        Text("Failed to load details: \(error)")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Location Coordinates")
                            .font(.headline)
                        Text("X: \(hut.x)")
                        Text("Y: \(hut.y)")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                .padding()
            }
        }
        .navigationTitle(hut.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await apiService.fetchHutDetail(assetId: String(hut.assetId))
        }
    }
}

struct StatusBadge: View {
    let status: String
    
    var color: Color {
        switch status.uppercased() {
        case "OPEN": return .green
        case "CLSD": return .red
        default: return .orange
        }
    }
    
    var body: some View {
        Text(status)
            .font(.caption)
            .fontWeight(.bold)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(8)
    }
}
