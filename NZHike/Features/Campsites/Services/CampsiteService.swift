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
        
        Task.detached(priority: .userInitiated) {
            var loadedCampsites: [Campsite] = []
            var loadedRecommendedCampsites: [Campsite] = []
            var errorMsg: String?
            
            guard let url = Bundle.main.url(forResource: "allCampsites", withExtension: "json") else {
                errorMsg = "allCampsites.json file not found in bundle"
                await MainActor.run {
                    self.errorMessage = errorMsg
                    self.isLoading = false
                }
                return
            }
            
            guard let data = try? Data(contentsOf: url) else {
                errorMsg = "Failed to read allCampsites.json data"
                await MainActor.run {
                    self.errorMessage = errorMsg
                    self.isLoading = false
                }
                return
            }
            
            do {
                loadedCampsites = try JSONDecoder().decode([Campsite].self, from: data)
                
                // Hardcoded IDs to match what was in recommendedAssetIds
                let targetIds: Set<Int> = [
                    100065349, 100065488, 100066095, 100044315, 100031362
                ]
                
                loadedRecommendedCampsites = loadedCampsites.filter { targetIds.contains($0.assetId) }
                
                await MainActor.run {
                    self.allCampsites = loadedCampsites
                    self.recommendedCampsites = loadedRecommendedCampsites
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to decode allCampsites.json: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
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
