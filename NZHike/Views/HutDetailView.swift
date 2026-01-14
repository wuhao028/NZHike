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
                // Header Image
                if let detail = apiService.hutDetail, 
                   let thumb = detail.introductionThumbnail, 
                   let url = URL(string: thumb) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .overlay(ProgressView())
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .overlay(
                                    Image(systemName: "house.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(.secondary)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(height: 240)
                    .clipped()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 200)
                        .overlay(
                            Image(systemName: "house.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)
                        )
                }
                
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
                        
                        if let category = detail.hutCategory {
                            HStack {
                                Image(systemName: "tag.fill")
                                Text("Category: \(category)")
                            }
                            .font(.subheadline)
                        }
                        
                        if let proximity = detail.proximityToRoadEnd {
                            HStack {
                                Image(systemName: "figure.walk")
                                Text("Proximity: \(proximity)")
                            }
                            .font(.subheadline)
                        }
                        
                        if let bookable = detail.bookable {
                            HStack {
                                Image(systemName: bookable ? "checkmark.circle.fill" : "xmark.circle.fill")
                                Text(bookable ? "Bookable" : "Not Bookable")
                            }
                            .font(.subheadline)
                            .foregroundColor(bookable ? .green : .secondary)
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
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Location")
                            .font(.headline)
                        
                        LocationMapView(easting: hut.x, northing: hut.y, title: hut.name)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Coordinates (NZTM)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("E: \(Int(hut.x)) N: \(Int(hut.y))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle(hut.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    favoritesManager.toggleFavorite(hut: hut)
                }) {
                    Image(systemName: favoritesManager.isFavorite(hutId: hut.id) ? "heart.fill" : "heart")
                        .foregroundColor(favoritesManager.isFavorite(hutId: hut.id) ? .red : .primary)
                }
            }
        }
        .task {
            await apiService.fetchHutDetail(assetId: String(hut.assetId))
        }
    }
    
    @EnvironmentObject var favoritesManager: FavoritesManager
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
