//
//  Campsite.swift
//  NZHike
//
//  Created by wuhao028 on 12/01/2026.
//

import Foundation

struct Campsite: Codable, Identifiable, Hashable {
    let assetId: Int
    let name: String
    let status: String
    let region: String?
    let x: Double
    let y: Double
    
    var id: Int {
        assetId
    }
}
