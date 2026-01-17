//
//  FavoriteCategory.swift
//  NZHike
//
//  Created by wuhao028 on 18/01/2026.
//

import Foundation

enum FavoriteCategory: String, CaseIterable, Identifiable {
    case all = "All"
    case tracks = "Tracks"
    case huts = "Huts"
    case campsites = "Campsites"
    
    var id: String { self.rawValue }
}
