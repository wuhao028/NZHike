//
//  FavoritesManager.swift
//  NZHike
//
//  Created by wuhao028 on 09/01/2026.
//

import Foundation
import CoreData
import Combine

@MainActor
class FavoritesManager: ObservableObject {
    @Published var favoriteTracks: [Track] = []
    @Published var favoriteTrackIds: Set<String> = []
    
    @Published var favoriteHuts: [Hut] = []
    @Published var favoriteHutIds: Set<Int> = []
    
    @Published var favoriteCampsites: [Campsite] = []
    @Published var favoriteCampsiteIds: Set<Int> = []
    
    private let persistenceController = PersistenceController.shared
    
    init() {
        loadFavorites()
    }
    
    func loadFavorites() {
        // Load Tracks (Core Data)
        let context = persistenceController.container.viewContext
        let request: NSFetchRequest<FavoriteTrackEntity> = FavoriteTrackEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FavoriteTrackEntity.favoritedAt, ascending: false)]
        
        do {
            let entities = try context.fetch(request)
            favoriteTracks = entities.map { Track(from: $0) }
            favoriteTrackIds = Set(favoriteTracks.map { $0.id })
        } catch {
            print("Failed to load favorites: \(error.localizedDescription)")
            favoriteTracks = []
            favoriteTrackIds = []
        }
        
        // Load Huts (JSON)
        loadHutFavorites()
        
        // Load Campsites (JSON)
        loadCampsiteFavorites()
    }
    
    func loadHutFavorites() {
        let url = getDocumentsDirectory().appendingPathComponent("favorite_huts.json")
        if let data = try? Data(contentsOf: url),
           let huts = try? JSONDecoder().decode([Hut].self, from: data) {
            favoriteHuts = huts
            favoriteHutIds = Set(huts.map { $0.id })
        } else {
            favoriteHuts = []
            favoriteHutIds = []
        }
    }
    
    func saveHutFavorites() {
        let url = getDocumentsDirectory().appendingPathComponent("favorite_huts.json")
        if let data = try? JSONEncoder().encode(favoriteHuts) {
            try? data.write(to: url)
        }
    }
    
    func loadCampsiteFavorites() {
        let url = getDocumentsDirectory().appendingPathComponent("favorite_campsites.json")
        if let data = try? Data(contentsOf: url),
           let campsites = try? JSONDecoder().decode([Campsite].self, from: data) {
            favoriteCampsites = campsites
            favoriteCampsiteIds = Set(campsites.map { $0.id })
        } else {
            favoriteCampsites = []
            favoriteCampsiteIds = []
        }
    }
    
    func saveCampsiteFavorites() {
        let url = getDocumentsDirectory().appendingPathComponent("favorite_campsites.json")
        if let data = try? JSONEncoder().encode(favoriteCampsites) {
            try? data.write(to: url)
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func toggleFavorite(track: Track) {
        let context = persistenceController.container.viewContext
        
        // Check if already favorited
        let request: NSFetchRequest<FavoriteTrackEntity> = FavoriteTrackEntity.fetchRequest()
        request.predicate = NSPredicate(format: "assetId == %@", track.assetId)
        
        if let existingEntity = try? context.fetch(request).first {
            // Remove from favorites
            context.delete(existingEntity)
            favoriteTrackIds.remove(track.id)
        } else {
            // Add to favorites
            let entity = track.toFavoriteEntity(context: context)
            favoriteTrackIds.insert(track.id)
        }
        
        do {
            try context.save()
            // Reload to update the list - logic from original code, but we can just update local arrays to save perf?
            // Original code reloads, I'll keep it consistent for Tracks.
            loadFavorites() 
        } catch {
            print("Failed to save favorite: \(error.localizedDescription)")
        }
    }
    
    func toggleFavorite(hut: Hut) {
        if favoriteHutIds.contains(hut.id) {
            // Remove
            favoriteHuts.removeAll { $0.id == hut.id }
            favoriteHutIds.remove(hut.id)
        } else {
            // Add
            favoriteHuts.append(hut)
            favoriteHutIds.insert(hut.id)
        }
        saveHutFavorites()
    }
    
    func toggleFavorite(campsite: Campsite) {
        if favoriteCampsiteIds.contains(campsite.id) {
            // Remove
            favoriteCampsites.removeAll { $0.id == campsite.id }
            favoriteCampsiteIds.remove(campsite.id)
        } else {
            // Add
            favoriteCampsites.append(campsite)
            favoriteCampsiteIds.insert(campsite.id)
        }
        saveCampsiteFavorites()
    }
    
    func isFavorite(trackId: String) -> Bool {
        favoriteTrackIds.contains(trackId)
    }
    
    func isFavorite(hutId: Int) -> Bool {
        favoriteHutIds.contains(hutId)
    }
    
    func isFavorite(campsiteId: Int) -> Bool {
        favoriteCampsiteIds.contains(campsiteId)
    }
    
    func getFavoriteTracks() -> [Track] {
        favoriteTracks
    }
}
