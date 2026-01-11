//
//  HutDetail.swift
//  NZHike
//
//  Created by wuhao028 on 09/01/2026.
//

import Foundation

struct HutDetail: Codable {
    let assetId: Int
    let name: String
    let introduction: String?
    let introductionThumbnail: String?
    let facilities: [String]?
    let numberOfBunks: Int?
    let status: String
    let region: String?
    let place: String?
    let locationString: String?
    let staticLink: String?
    let x: Double
    let y: Double
    
    // Additional fields that might be present
    let hutCategory: [String]?
    let bookable: Bool?
}
