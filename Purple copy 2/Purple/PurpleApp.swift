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
    var dateCategoriesEnvironment: DateCategoriesEnvironment

    init() {
        self.dateCategoriesEnvironment = DateCategoriesEnvironment(context: persistenceController.container.viewContext)
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(CategoryEnvironment(context: persistenceController.container.viewContext))
                .environmentObject(TransactionsEnvironment(context: persistenceController.container.viewContext))
                .environmentObject(dateCategoriesEnvironment)
        }
    }
}
