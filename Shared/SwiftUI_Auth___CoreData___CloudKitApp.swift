//
//  SwiftUI_Auth___CoreData___CloudKitApp.swift
//  Shared
//
//  Created by Ashraful Islam Rupu on 2/27/22.
//

import SwiftUI
import Firebase
import CoreData

@main
struct SwiftUI_Auth___CoreData___CloudKitApp: App {
    let persistenceController = PersistenceController.shared
    
    
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            SignUpView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
