//
//  HutService.swift
//  NZHike
//
//  Created by wuhao028 on 09/01/2026.
//

import Foundation

@MainActor
class HutService: ObservableObject {
    @Published var allHuts: [Hut] = []
    @Published var recommendedHuts: [Hut] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Hardcoded recommended huts by assetId
    // These correspond to known popular huts like Angelus, Mueller, etc.
    // Based on search results in exploration phase:
    // Angelus Hut: 100081275
    // Mueller Hut: Not found in precise search but Sefton Bivouac (100063446) is nearby?
    // Let's stick to ones we saw in the JSON or very popular ones we can find.
    // From JSON view earlier:
    // 100081275: Angelus Hut
    // 100062554: Woolshed Creek Hut
    // 100030357: Staircase Hut (Otago)
    // 100059655: Welcome Flat Hut (West Coast) - very popular
    // 100062738: Carrington Hut (Canterbury)
    // 100058625: George Sound Hut (Fiordland)
    
    private let recommendedAssetIds: Set<Int> = [
        100081275, // Angelus Hut
        100062554, // Woolshed Creek Hut
        100059655, // Welcome Flat Hut
        100030357, // Staircase Hut
        100062738, // Carrington Hut
        100058625  // George Sound Hut
    ]
    
    init() {
        loadHuts()
    }
    
    private func loadHuts() {
        isLoading = true
        
        Task.detached(priority: .userInitiated) {
            var loadedHuts: [Hut] = []
            var loadedRecommendedHuts: [Hut] = []
            var errorMsg: String?
            
            guard let url = Bundle.main.url(forResource: "allHuts", withExtension: "json") else {
                errorMsg = "allHuts.json file not found in bundle"
                await MainActor.run {
                    self.errorMessage = errorMsg
                    self.isLoading = false
                }
                return
            }
            
            guard let data = try? Data(contentsOf: url) else {
                errorMsg = "Failed to read allHuts.json data"
                await MainActor.run {
                    self.errorMessage = errorMsg
                    self.isLoading = false
                }
                return
            }
            
            do {
                loadedHuts = try JSONDecoder().decode([Hut].self, from: data)
                // Filter recommended huts
                // We need to capture the set safely. Since it's a let constant, it should be fine or we can copy it.
                // However, accessing self.recommendedAssetIds inside detached task might be tricky if it captures self.
                // Better to make a local copy of ids or access a static/let property.
                // The recommendedAssetIds is a private let, capturing self is fine but we should be careful.
                // Actually, let's just define the IDs inside the task or pass them in? 
                // It's a constant property, so it's safe to read? 
                // Accessing 'self' in detached task technically captures it.
                // Let's rely on the fact that these are simple value types.
                
                let idsToFilter = await self.recommendedAssetIds // Jump to main to read valid property? 
                // No, just creating a local set here is easier to avoid actor crossing for a simple set.
                let targetIds: Set<Int> = [
                    100081275, 100062554, 100059655, 100030357, 100062738, 100058625
                ]
                
                loadedRecommendedHuts = loadedHuts.filter { targetIds.contains($0.assetId) }
                
                await MainActor.run {
                    self.allHuts = loadedHuts
                    self.recommendedHuts = loadedRecommendedHuts
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to decode allHuts.json: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    func searchHuts(query: String) -> [Hut] {
        guard !query.isEmpty else { return allHuts }
        let lowercasedQuery = query.lowercased()
        return allHuts.filter { hut in
            hut.name.lowercased().contains(lowercasedQuery) ||
            (hut.region?.lowercased().contains(lowercasedQuery) ?? false)
        }
    }
}
