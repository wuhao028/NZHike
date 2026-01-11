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
        errorMessage = nil
        
        guard let url = Bundle.main.url(forResource: "allHuts", withExtension: "json") else {
            errorMessage = "allHuts.json file not found in bundle"
            isLoading = false
            return
        }
        
        guard let data = try? Data(contentsOf: url) else {
            errorMessage = "Failed to read allHuts.json data"
            isLoading = false
            return
        }
        
        do {
            allHuts = try JSONDecoder().decode([Hut].self, from: data)
            
            // Filter recommended huts
            recommendedHuts = allHuts.filter { recommendedAssetIds.contains($0.assetId) }
            
            isLoading = false
        } catch {
            errorMessage = "Failed to decode allHuts.json: \(error.localizedDescription)"
            isLoading = false
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
