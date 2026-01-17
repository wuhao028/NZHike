//
//  Track.swift
//  NZHike
//
//  Created by wuhao028 on 09/01/2026.
//

import Foundation
import CoreData

struct Track: Codable, Identifiable, Hashable {
    var assetId: String
    var name: String
    var region: [String]
    var x: Double // X coordinate
    var y: Double // Y coordinate
    var line: [[[Double]]] // Path coordinates array
    
    // Optional details from DOC API
    var difficulty: String? = nil
    var duration: String? = nil
    var distance: String? = nil
    var description: String? = nil
    var docId: String? = nil // DOC API ID
    
    // For Identifiable protocol
    var id: String {
        assetId
    }
    
    enum CodingKeys: String, CodingKey {
        case assetId
        case name
        case region
        case x
        case y
        case line
        case difficulty
        case duration
        case distance
        case description
        case docId = "doc_id"
    }
    
    // Computed property: get region string for display
    var regionString: String {
        region.joined(separator: ", ")
    }
    
    // Computed property: get center coordinate
    var centerCoordinate: (x: Double, y: Double) {
        (x, y)
    }
}

// MARK: - Core Data Extensions
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

struct TrackDetail: Codable {
    let assetId: String
    let name: String
    let introduction: String
    let introductionThumbnail: String
    let permittedActivities: [String]
    let distance: String
    let walkDuration: String
    let walkDurationCategory: [String]
    let walkTrackCategory: [String]
    
    let wheelchairsAndBuggies: String?
    let mtbDuration: String?
    let mtbDurationCategory: [String]
    let mtbTrackCategory: [String]
    let kayakingDuration: String?
    
    let dogsAllowed: String
    let locationString: String
    let locationArray: [String]
    let region: [String]
    let staticLink: String
    
    let x: Double
    let y: Double
    
    /// [[[Double]]] line coordinates
    let line: [[[Double]]]
}
