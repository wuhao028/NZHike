//
//  Track.swift
//  NZHike
//
//  Created by wuhao028 on 09/01/2026.
//

import Foundation

struct Track: Codable, Identifiable, Hashable {
    let assetId: String
    let name: String
    let region: [String]
    let x: Double // X coordinate
    let y: Double // Y coordinate
    let line: [[[Double]]] // Path coordinates array
    
    // Optional details from DOC API
    var difficulty: String?
    var duration: String?
    var distance: String?
    var description: String?
    var docId: String? // DOC API ID
    
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
