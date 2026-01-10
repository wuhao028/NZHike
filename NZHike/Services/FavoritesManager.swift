//
//  FavoritesManager.swift
//  NZHike
//
//  Created by wuhao028 on 09/01/2026.
//

import Foundation

@MainActor
class FavoritesManager: ObservableObject {
    @Published var favoriteTrackIds: Set<String> = []
    
    private let favoritesKey = "favorite_track_ids"
    
    init() {
        loadFavorites()
    }
    
    func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let ids = try? JSONDecoder().decode(Set<String>.self, from: data) {
            favoriteTrackIds = ids
        }
    }
    
    func saveFavorites() {
        if let data = try? JSONEncoder().encode(favoriteTrackIds) {
            UserDefaults.standard.set(data, forKey: favoritesKey)
        }
    }
    
    func toggleFavorite(trackId: String) {
        if favoriteTrackIds.contains(trackId) {
            favoriteTrackIds.remove(trackId)
        } else {
            favoriteTrackIds.insert(trackId)
        }
        saveFavorites()
    }
    
    func isFavorite(trackId: String) -> Bool {
        favoriteTrackIds.contains(trackId)
    }
    
    func getFavoriteTracks(from tracks: [Track]) -> [Track] {
        tracks.filter { favoriteTrackIds.contains($0.id) }
    }
}
