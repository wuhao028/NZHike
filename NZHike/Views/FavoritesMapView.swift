//
//  FavoritesMapView.swift
//  NZHike
//
//  Created by Antigravity on 14/01/2026.
//

import SwiftUI
import MapKit

struct FavoritesMapView: View {
    @EnvironmentObject var favoritesManager: FavoritesManager
    @Binding var selectedCategory: FavoriteCategory
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -41.2865, longitude: 174.7762), // NZ Center approx
        span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
    )
    
    var annotationItems: [FavoriteMapItem] {
        var items: [FavoriteMapItem] = []
        
        // Tracks
        if selectedCategory == .all || selectedCategory == .tracks {
            for track in favoritesManager.favoriteTracks {
                // Ignore tracks without coordinates (some recommended tracks might be initialized with 0,0)
                if track.x != 0 && track.y != 0 {
                    let coord = CoordinateConverter.nztmToWgs84(easting: track.x, northing: track.y)
                    items.append(FavoriteMapItem(
                        id: "track-\(track.id)",
                        name: track.name,
                        coordinate: coord,
                        type: .tracks,
                        track: track
                    ))
                }
            }
        }
        
        // Huts
        if selectedCategory == .all || selectedCategory == .huts {
            for hut in favoritesManager.favoriteHuts {
                if hut.x != 0 && hut.y != 0 {
                    let coord = CoordinateConverter.nztmToWgs84(easting: hut.x, northing: hut.y)
                    items.append(FavoriteMapItem(
                        id: "hut-\(hut.id)",
                        name: hut.name,
                        coordinate: coord,
                        type: .huts,
                        hut: hut
                    ))
                }
            }
        }
        
        // Campsites
        if selectedCategory == .all || selectedCategory == .campsites {
            for campsite in favoritesManager.favoriteCampsites {
                if campsite.x != 0 && campsite.y != 0 {
                    let coord = CoordinateConverter.nztmToWgs84(easting: campsite.x, northing: campsite.y)
                    items.append(FavoriteMapItem(
                        id: "campsite-\(campsite.id)",
                        name: campsite.name,
                        coordinate: coord,
                        type: .campsites,
                        campsite: campsite
                    ))
                }
            }
        }
        
        return items
    }
    
    @StateObject private var locationManager = LocationManager()
    @State private var selectedItem: FavoriteMapItem?
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: annotationItems) { item in
                MapAnnotation(coordinate: item.coordinate) {
                    VStack {
                        ZStack {
                            Circle()
                                .fill(colorForType(item.type))
                                .frame(width: 30, height: 30)
                                .shadow(radius: 2)
                            
                            Image(systemName: iconForType(item.type))
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .bold))
                        }
                        
                        if selectedItem?.id == item.id {
                            Text(item.name)
                                .font(.caption2)
                                .padding(4)
                                .background(Color(.systemBackground).opacity(0.8))
                                .cornerRadius(4)
                                .fixedSize()
                        }
                    }
                    .onTapGesture {
                        withAnimation {
                            if selectedItem?.id == item.id {
                                selectedItem = nil
                            } else {
                                selectedItem = item
                            }
                        }
                    }
                }
            }
            
            // Map Controls
            VStack {
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        // Current Location Button
                        Button(action: {
                            if let userLoc = locationManager.location?.coordinate {
                                withAnimation {
                                    region.center = userLoc
                                    region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                }
                            } else {
                                locationManager.requestLocation()
                            }
                        }) {
                            Image(systemName: "location.fill")
                                .padding(10)
                                .background(Color(.systemBackground))
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        
                        // Zoom Controls
                        VStack(spacing: 0) {
                            Button(action: { zoom(by: 0.5) }) {
                                Image(systemName: "plus")
                                    .padding(10)
                                    .frame(width: 44, height: 44)
                            }
                            
                            Divider()
                                .frame(width: 30)
                            
                            Button(action: { zoom(by: 2.0) }) {
                                Image(systemName: "minus")
                                    .padding(10)
                                    .frame(width: 44, height: 44)
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                        .shadow(radius: 4)
                    }
                    .padding()
                }
                Spacer()
                
                if let selected = selectedItem {
                    FavoritePopupCard(item: selected)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding()
                }
            }
        }
        .onAppear {
            setInitialRegion()
            locationManager.requestLocation()
        }
        .onChange(of: selectedCategory) { _ in
            setInitialRegion()
        }
    }
    
    private func zoom(by factor: Double) {
        withAnimation {
            region.span.latitudeDelta *= factor
            region.span.longitudeDelta *= factor
        }
    }
    
    private func setInitialRegion() {
        let items = annotationItems
        guard !items.isEmpty else { return }
        
        let lats = items.map { $0.coordinate.latitude }
        let lons = items.map { $0.coordinate.longitude }
        
        let minLat = lats.min()!
        let maxLat = lats.max()!
        let minLon = lons.min()!
        let maxLon = lons.max()!
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.5 + 0.5,
            longitudeDelta: (maxLon - minLon) * 1.5 + 0.5
        )
        
        region = MKCoordinateRegion(center: center, span: span)
    }
    
    private func colorForType(_ type: FavoriteCategory) -> Color {
        switch type {
        case .tracks: return .green
        case .huts: return .blue
        case .campsites: return .orange
        case .all: return .gray
        }
    }
    
    private func iconForType(_ type: FavoriteCategory) -> String {
        switch type {
        case .tracks: return "figure.walk"
        case .huts: return "house.fill"
        case .campsites: return "tent.fill"
        case .all: return "mappin"
        }
    }
}

struct FavoriteMapItem: Identifiable {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
    let type: FavoriteCategory
    
    var track: Track?
    var hut: Hut?
    var campsite: Campsite?
}

struct FavoritePopupCard: View {
    let item: FavoriteMapItem
    
    var body: some View {
        Group {
            if let track = item.track {
                NavigationLink(destination: TrackDetailView(trackId: track.id)) {
                    cardContent
                }
            } else if let hut = item.hut {
                NavigationLink(destination: HutDetailView(hut: hut)) {
                    cardContent
                }
            } else if let campsite = item.campsite {
                NavigationLink(destination: CampsiteDetailView(campsite: campsite)) {
                    cardContent
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 5)
    }
    
    var cardContent: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(colorForType(item.type).opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: iconForType(item.type))
                    .foregroundColor(colorForType(item.type))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.headline)
                    .lineLimit(1)
                Text(item.type.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    private func colorForType(_ type: FavoriteCategory) -> Color {
        switch type {
        case .tracks: return .green
        case .huts: return .blue
        case .campsites: return .orange
        case .all: return .gray
        }
    }
    
    private func iconForType(_ type: FavoriteCategory) -> String {
        switch type {
        case .tracks: return "figure.walk"
        case .huts: return "house.fill"
        case .campsites: return "tent.fill"
        case .all: return "mappin"
        }
    }
}
