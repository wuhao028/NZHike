//
//  Hut.swift
//  NZHike
//
//  Created by wuhao028 on 09/01/2026.
//

import Foundation

struct Hut: Codable, Identifiable, Hashable {
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
