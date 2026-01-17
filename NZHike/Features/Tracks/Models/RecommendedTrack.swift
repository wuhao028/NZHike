//
//  RecommendedTrack.swift
//  NZHike
//
//  Created by wuhao028 on 09/01/2026.
//

import Foundation

struct RecommendedTrack: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let region: String
    let difficulty: String
    let duration: String
    let distance: String
    let description: String
    let imageName: String
    let docId: String? // DOC API ID
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case region
        case difficulty
        case duration
        case distance
        case description
        case imageName = "image_name"
        case docId = "doc_id"
    }
}
