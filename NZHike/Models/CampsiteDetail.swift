//
//  CampsiteDetail.swift
//  NZHike
//
//  Created by wuhao028 on 12/01/2026.
//

import Foundation

struct CampsiteDetail: Codable {
    let assetId: Int
    let name: String
    let introduction: String?
    let introductionThumbnail: String?
    let facilities: [String]?
    let numberOfPoweredSites: Int?
    let numberOfUnpoweredSites: Int?
    let status: String
    let region: String?
    let place: String?
    let locationString: String?
    let staticLink: String?
    let x: Double
    let y: Double
    
    // Additional fields that might be present
    let campsiteCategory: String?
    let bookable: Bool?
    let landscape: [String]?
    let access: [String]?
    let activities: [String]?
    let dogsAllowed: String?
}
