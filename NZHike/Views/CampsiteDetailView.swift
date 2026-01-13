//
//  CampsiteDetailView.swift
//  NZHike
//
//  Created by wuhao028 on 12/01/2026.
//

import SwiftUI

struct CampsiteDetailView: View {
    let campsite: Campsite
    @StateObject private var apiService = DOCAPIService()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Image
                if let detail = apiService.campsiteDetail, 
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
                                    Image(systemName: "tent.fill")
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
                            Image(systemName: "tent.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)
                        )
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(campsite.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    if let region = campsite.region {
                        HStack {
                            Image(systemName: "map")
                            Text(region)
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        StatusBadge(status: campsite.status)
                        Spacer()
                    }
                    
                    if apiService.isLoading {
                        ProgressView("Loading details...")
                    } else if let detail = apiService.campsiteDetail {
                        Divider()
                        
                        if let intro = detail.introduction {
                            Text("About")
                                .font(.headline)
                            Text(intro)
                                .font(.body)
                        }
                        
                        // Display powered/unpowered sites if available
                        if let powered = detail.numberOfPoweredSites, powered > 0 {
                            HStack {
                                Image(systemName: "bolt.fill")
                                Text("\(powered) Powered Sites")
                            }
                            .font(.subheadline)
                        }
                        
                        if let unpowered = detail.numberOfUnpoweredSites, unpowered > 0 {
                            HStack {
                                Image(systemName: "bolt.slash.fill")
                                Text("\(unpowered) Unpowered Sites")
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
                        
                        if let category = detail.campsiteCategory {
                            HStack {
                                Image(systemName: "tag.fill")
                                Text("Category: \(category)")
                            }
                            .font(.subheadline)
                        }
                        
                        if let landscapes = detail.landscape, !landscapes.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Landscape")
                                    .font(.headline)
                                    .padding(.top, 4)
                                
                                FlowLayout(spacing: 8) {
                                    ForEach(landscapes, id: \.self) { item in
                                        ChipView(text: item, color: .green)
                                    }
                                }
                            }
                        }
                        
                        if let activities = detail.activities, !activities.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Activities")
                                    .font(.headline)
                                    .padding(.top, 4)
                                
                                FlowLayout(spacing: 8) {
                                    ForEach(activities, id: \.self) { item in
                                        ChipView(text: item, color: .blue)
                                    }
                                }
                            }
                        }
                        
                        if let access = detail.access, !access.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Access")
                                    .font(.headline)
                                    .padding(.top, 4)
                                
                                ForEach(access, id: \.self) { item in
                                    Text("• \(item)")
                                        .font(.subheadline)
                                }
                            }
                        }
                        
                        if let dogs = detail.dogsAllowed {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Dogs Allowed")
                                    .font(.headline)
                                    .padding(.top, 4)
                                
                                // Simple HTML-stripping or just display text
                                // For now, simple text display. A real app might parse HTML link.
                                Text(dogs.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
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
                        Text("X: \(campsite.x)")
                        Text("Y: \(campsite.y)")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                .padding()
            }
        }
        .navigationTitle(campsite.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    favoritesManager.toggleFavorite(campsite: campsite)
                }) {
                    Image(systemName: favoritesManager.isFavorite(campsiteId: campsite.id) ? "heart.fill" : "heart")
                        .foregroundColor(favoritesManager.isFavorite(campsiteId: campsite.id) ? .red : .primary)
                }
            }
        }
        .task {
            await apiService.fetchCampsiteDetail(assetId: String(campsite.assetId))
        }
    }
    
    @EnvironmentObject var favoritesManager: FavoritesManager
}
