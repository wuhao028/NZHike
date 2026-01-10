//
//  Track+CoreData.swift
//  NZHike
//
//  Created by wuhao028 on 09/01/2026.
//

import Foundation
import CoreData

extension Track {
    init(from entity: TrackEntity) {
        self.assetId = entity.assetId ?? ""
        self.name = entity.name ?? ""
        
        // Decode region array from binary data
        if let regionData = entity.regionData,
           let regions = try? JSONDecoder().decode([String].self, from: regionData) {
            self.region = regions
        } else {
            self.region = []
        }
        
        self.x = entity.x
        self.y = entity.y
        
        // Decode line coordinates from binary data
        if let lineData = entity.lineData,
           let lines = try? JSONDecoder().decode([[[Double]]].self, from: lineData) {
            self.line = lines
        } else {
            self.line = []
        }
        
        self.difficulty = entity.difficulty
        self.duration = entity.duration
        self.distance = entity.distance
        self.description = entity.descriptionText
        self.docId = entity.docId
    }
    
    func toEntity(context: NSManagedObjectContext) -> TrackEntity {
        let entity = TrackEntity(context: context)
        entity.assetId = self.assetId
        entity.name = self.name
        entity.x = self.x
        entity.y = self.y
        entity.difficulty = self.difficulty
        entity.duration = self.duration
        entity.distance = self.distance
        entity.descriptionText = self.description
        entity.docId = self.docId
        
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
