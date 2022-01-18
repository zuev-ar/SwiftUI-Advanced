//
//  SwiftUI_AdvancedApp.swift
//  SwiftUI-Advanced
//
//  Created by Arkasha Zuev on 18.01.2022.
//

import SwiftUI

@main
struct SwiftUI_AdvancedApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
