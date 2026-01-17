//
//  HutDetailView.swift
//  NZHike
//
//  Created by wuhao028 on 09/01/2026.
//

import SwiftUI

struct HutDetailView: View {
    @EnvironmentObject var apiService: DOCAPIService
    @EnvironmentObject var favoritesManager: FavoritesManager
    
    let hut: Hut
    
    var body: some View {
        HutDetailContentView(
            hut: hut,
            apiService: apiService,
            favoritesManager: favoritesManager
        )
    }
}

struct HutDetailContentView: View {
    @StateObject private var viewModel: HutDetailViewModel
    @Environment(\.dismiss) var dismiss
    
    init(hut: Hut, apiService: DOCAPIService, favoritesManager: FavoritesManager) {
        _viewModel = StateObject(wrappedValue: HutDetailViewModel(
            hut: hut,
            apiService: apiService,
            favoritesManager: favoritesManager
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header Image
                ZStack(alignment: .top) {
                    Group {
                        if let imageUrl = viewModel.hutDetail?.introductionThumbnail, let url = URL(string: imageUrl) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                colorPlaceholder
                            }
                        } else {
                            colorPlaceholder
                        }
                    }
                    .frame(height: 250)
                    .clipped()
                    
                    // Top Bar
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .padding(12)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        Button(action: { viewModel.toggleFavorite() }) {
                            Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                                .font(.system(size: 18, weight: .semibold))
                                .padding(12)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                .foregroundColor(viewModel.isFavorite ? .red : .primary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 50)
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    // Title and Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.hut.name)
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.bold)
                        
                        if let region = viewModel.hut.region {
                            Text(region)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    
                    if viewModel.isLoading {
                        ProgressView("Loading details...")
                            .frame(maxWidth: .infinity, minHeight: 100)
                    } else if let detail = viewModel.hutDetail {
                        VStack(alignment: .leading, spacing: 20) {
                            // Stats/Quick Info
                            HStack(spacing: 20) {
                                HutStatItem(icon: "bed.double.fill", title: "Bunks", value: String(detail.numberOfBunks ?? 0))
                                HutStatItem(icon: "tag.fill", title: "Category", value: detail.hutCategory ?? "Standard")
                            }
                            .padding(.horizontal)
                            
                            Divider()
                                .padding(.horizontal)
                            
                            // Introduction
                            if let introduction = detail.introduction, !introduction.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("About this hut")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                    
                                    Text(introduction.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression))
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        .lineSpacing(4)
                                }
                                .padding(.horizontal)
                                
                                Divider()
                                    .padding(.horizontal)
                            }
                            
                            // Facilities
                            if let facilities = detail.facilities, !facilities.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Facilities")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                    
                                    FlowLayout(spacing: 8) {
                                        ForEach(facilities, id: \.self) { facility in
                                            Text(facility)
                                                .font(.caption)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 5)
                                                .background(Color.blue.opacity(0.1))
                                                .foregroundColor(.blue)
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                
                                Divider()
                                    .padding(.horizontal)
                            }
                        }
                    }
                    
                    if viewModel.hut.x != 0 && viewModel.hut.y != 0 {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Location")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            LocationMapView(easting: viewModel.hut.x, northing: viewModel.hut.y, title: viewModel.hut.name)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Coordinates (NZTM)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("E: \(Int(viewModel.hut.x)) N: \(Int(viewModel.hut.y))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .task {
            await viewModel.fetchDetails()
        }
    }
    
    private var colorPlaceholder: some View {
        Rectangle()
            .fill(Color.green.opacity(0.2))
            .overlay(
                Image(systemName: "house.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green.opacity(0.5))
            )
    }
}

struct HutStatItem: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.green)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
        }
    }
}
