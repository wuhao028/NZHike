//
//  FavoritesManager.swift
//  NZHike
//
//  Created by wuhao028 on 09/01/2026.
//

import Foundation
import CoreData

@MainActor
class FavoritesManager: ObservableObject {
    @Published var favoriteTracks: [Track] = []
    @Published var favoriteTrackIds: Set<String> = []
    
    private let persistenceController = PersistenceController.shared
    
    init() {
        loadFavorites()
    }
    
    func loadFavorites() {
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
            loadFavorites() // Reload to update the list
        } catch {
            print("Failed to save favorite: \(error.localizedDescription)")
        }
    }
    
    func isFavorite(trackId: String) -> Bool {
        favoriteTrackIds.contains(trackId)
    }
    
    func getFavoriteTracks() -> [Track] {
        favoriteTracks
    }
}
