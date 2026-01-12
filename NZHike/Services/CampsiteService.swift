//
//  CampsiteService.swift
//  NZHike
//
//  Created by wuhao028 on 12/01/2026.
//

import Foundation

@MainActor
class CampsiteService: ObservableObject {
    @Published var allCampsites: [Campsite] = []
    @Published var recommendedCampsites: [Campsite] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Recommended campsites by assetId
    private let recommendedAssetIds: Set<Int> = [
        100065349, // Puriri Bay (Whangaruru North Head) Campsite
        100065488, // Kiosk Creek Campsite
        100066095, // Butchers Flat Campsite
        100044315, // Wentworth Valley Campground
        100031362  // Ōtaki Forks Campsite
    ]
    
    init() {
        loadCampsites()
    }
    
    private func loadCampsites() {
        isLoading = true
        errorMessage = nil
        
        guard let url = Bundle.main.url(forResource: "allCampsites", withExtension: "json") else {
            errorMessage = "allCampsites.json file not found in bundle"
            isLoading = false
            return
        }
        
        guard let data = try? Data(contentsOf: url) else {
            errorMessage = "Failed to read allCampsites.json data"
            isLoading = false
            return
        }
        
        do {
            allCampsites = try JSONDecoder().decode([Campsite].self, from: data)
            
            // Filter recommended campsites
            recommendedCampsites = allCampsites.filter { recommendedAssetIds.contains($0.assetId) }
            
            isLoading = false
        } catch {
            errorMessage = "Failed to decode allCampsites.json: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func searchCampsites(query: String) -> [Campsite] {
        guard !query.isEmpty else { return allCampsites }
        let lowercasedQuery = query.lowercased()
        return allCampsites.filter { campsite in
            campsite.name.lowercased().contains(lowercasedQuery) ||
            (campsite.region?.lowercased().contains(lowercasedQuery) ?? false)
        }
    }
}
