//
//  PurpleApp.swift
//  Purple
//
//  Created by Farhad on 19/11/2022.
//

import SwiftUI

@main
struct PurpleApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
