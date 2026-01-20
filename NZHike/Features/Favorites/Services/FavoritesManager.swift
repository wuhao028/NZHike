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
        // Defer loading to avoid blocking init
        Task {
            loadFavorites()
        }
    }
    
    func loadFavorites() {
        // Load Tracks (Core Data) - Must be on Main Thread
        // But doing it in a Task ensures it runs in the next run loop turn at least? 
        // Actually, loadFavorites is called from Task in init, so it runs asynchronously to init.
        
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
        
        // Load Huts and Campsites (JSON) in background
        Task {
            await loadHutFavorites()
            await loadCampsiteFavorites()
        }
    }
    
    func loadHutFavorites() async {
        let docsDir = getDocumentsDirectory()
        
        await Task.detached {
            let url = docsDir.appendingPathComponent("favorite_huts.json")
            if let data = try? Data(contentsOf: url),
               let huts = try? JSONDecoder().decode([Hut].self, from: data) {
                await MainActor.run {
                    self.favoriteHuts = huts
                    self.favoriteHutIds = Set(huts.map { $0.id })
                }
            } else {
                await MainActor.run {
                    self.favoriteHuts = []
                    self.favoriteHutIds = []
                }
            }
        }.value
    }
    
    func saveHutFavorites() {
        let url = getDocumentsDirectory().appendingPathComponent("favorite_huts.json")
        Task.detached {
            // Need to capture data, accessing self.favoriteHuts on background is unsafe if it's main actor isolated.
            // But we are in a synchronous method on MainActor (implied).
            // So we should capture the data before dispatching.
        }
        // Correct approach for save: Capture the data to save
        let hutsToSave = favoriteHuts
        Task.detached {
            if let data = try? JSONEncoder().encode(hutsToSave) {
                try? data.write(to: url)
            }
        }
    }
    
    func loadCampsiteFavorites() async {
        let docsDir = getDocumentsDirectory()
        
        await Task.detached {
            let url = docsDir.appendingPathComponent("favorite_campsites.json")
            if let data = try? Data(contentsOf: url),
               let campsites = try? JSONDecoder().decode([Campsite].self, from: data) {
                await MainActor.run {
                    self.favoriteCampsites = campsites
                    self.favoriteCampsiteIds = Set(campsites.map { $0.id })
                }
            } else {
                await MainActor.run {
                    self.favoriteCampsites = []
                    self.favoriteCampsiteIds = []
                }
            }
        }.value
    }
    
    func saveCampsiteFavorites() {
        let url = getDocumentsDirectory().appendingPathComponent("favorite_campsites.json")
        let campsitesToSave = favoriteCampsites
        Task.detached {
            if let data = try? JSONEncoder().encode(campsitesToSave) {
                try? data.write(to: url)
            }
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
