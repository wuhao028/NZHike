//
//  Track+FavoriteCoreData.swift
//  NZHike
//
//  Created by wuhao028 on 09/01/2026.
//

import Foundation
import CoreData

extension Track {
    init(from favoriteEntity: FavoriteTrackEntity) {
        self.assetId = favoriteEntity.assetId ?? ""
        self.name = favoriteEntity.name ?? ""
        
        // Decode region array from binary data
        if let regionData = favoriteEntity.regionData,
           let regions = try? JSONDecoder().decode([String].self, from: regionData) {
            self.region = regions
        } else {
            self.region = []
        }
        
        self.x = favoriteEntity.x
        self.y = favoriteEntity.y
        
        // Decode line coordinates from binary data
        if let lineData = favoriteEntity.lineData,
           let lines = try? JSONDecoder().decode([[[Double]]].self, from: lineData) {
            self.line = lines
        } else {
            self.line = []
        }
        
        self.difficulty = favoriteEntity.difficulty
        self.duration = favoriteEntity.duration
        self.distance = favoriteEntity.distance
        self.description = favoriteEntity.descriptionText
        self.docId = favoriteEntity.docId
    }
    
    func toFavoriteEntity(context: NSManagedObjectContext) -> FavoriteTrackEntity {
        let entity = FavoriteTrackEntity(context: context)
        entity.assetId = self.assetId
        entity.name = self.name
        entity.x = self.x
        entity.y = self.y
        entity.difficulty = self.difficulty
        entity.duration = self.duration
        entity.distance = self.distance
        entity.descriptionText = self.description
        entity.docId = self.docId
        entity.favoritedAt = Date()
        
        // Encode region array to binary data
        if let regionData = try? JSONEncoder().encode(self.region) {
            entity.regionData = regionData
        }
        
        // Encode line coordinates to binary data
        if let lineData = try? JSONEncoder().encode(self.line) {
            entity.lineData = lineData
        }
        
        return entity
    }
}
