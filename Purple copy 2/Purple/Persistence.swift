//
//  Persistence.swift
//  Purple
//
//  Created by Farhad on 19/11/2022.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        

        // Populate DateEntity
        for index in 0..<10 {
            let newDateEntity = DateEntity(context: viewContext)
            newDateEntity.date = Date()
        }

        // Populate CategoryEntity
        for index in 0..<10 {
            let newCategoryEntity = CategoryEntity(context: viewContext)
            newCategoryEntity.categoryDate = Date()
            newCategoryEntity.categoryIndex = Int64(index)
            newCategoryEntity.id = UUID()
            newCategoryEntity.limit = Int64(100)
            newCategoryEntity.progressbar = false
            newCategoryEntity.limitTimeFrameRaw = LimitTimeFrame.Never.rawValue
        }
        do {
            try viewContext.save()
        } catch let error {
            print("Failed to save context: \(error)")
        }

        // Populate FinancialTransactionEntity
        for index in 0..<10 {
            let newFinancialTransactionEntity = FinancialTransactionEntity(context: viewContext)
            newFinancialTransactionEntity.amount = Int64(10)
            newFinancialTransactionEntity.date = Date()
            newFinancialTransactionEntity.id = UUID()
            newFinancialTransactionEntity.isRecurring = false
            newFinancialTransactionEntity.recurringFrequencyRaw = TimeFrame2.day.rawValue
            newFinancialTransactionEntity.title = "Transaction \(index)"
        }

        return result
    }()


    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Purple")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

