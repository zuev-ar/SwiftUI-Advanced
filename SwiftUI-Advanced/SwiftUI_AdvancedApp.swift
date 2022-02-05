//
//  SwiftUI_AdvancedApp.swift
//  SwiftUI-Advanced
//
//  Created by Arkasha Zuev on 18.01.2022.
//

import SwiftUI
import Firebase
import Purchases

@main
struct SwiftUI_AdvancedApp: App {
    let persistenceController = PersistenceController.shared

    init() {
        FirebaseApp.configure()
//        Purchases.configure(withAPIKey: "")
//        Purchases.logLevel = .debug
    }
    
    var body: some Scene {
        WindowGroup {
            SignupView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
