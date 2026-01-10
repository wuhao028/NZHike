//
//  NZHikeApp.swift
//  NZHike
//
//  Created by wuhao028 on 09/01/2026.
//

import SwiftUI

@main
struct NZHikeApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
