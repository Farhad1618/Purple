//
//  CiercleView.swift
//  Purple
//
//  Created by Farhad on 20/12/2022.
//

import SwiftUI
import CoreData

struct CircleItem: View {
    @EnvironmentObject var categories: CategoryEnvironment
    var namespace: Namespace.ID
    var category: CategoryEntity
    @Binding var show: Bool
    @State var selectedCategory: CategoryEntity?
    @State private var fallbackIDCounter = 0
    
    var body: some View {
        ZStack {
            let id = idForCategory()
            
            if category.progressbar == true {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.clear)
                
                    .frame(width: UIScreen.main.bounds.width * 0.7, height: 40)
                
                    .overlay(
                        ProgressBare(total: Double(category.limit), current: Double(categories.totalTransactionsForSelectedCategory(for: category)))
                            .id("progressbar")
                            .matchedGeometryEffect(id: "progressBare\(id)", in: namespace)
                    )
                
            }
            HStack{
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .foregroundColor(Color("Text2"))
                    .cornerRadius(10)
                    .padding(9)
                    .matchedGeometryEffect(id: "light\(id)", in: namespace)
                    .frame(width:63, height: 73.5)
                
                Spacer()
                
            }       .padding(.leading,8)
            
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.clear)
            
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.clear)
                    
                        .frame(width: UIScreen.main.bounds.width * 0.9, height: 63)
                        .overlay(
                            HStack {
                                
                                Text(predefinedCategories[Int(category.categoryIndex)])
                                    .font(.title)
                                    .fontWeight(.light)
                                    .foregroundColor(Color("Background"))
                                    .padding(8)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(10)
                                    .matchedGeometryEffect(id: "CategoryName\(id)", in: namespace)
                                    .padding(.horizontal,-7.5)
                                
                                // Text("\(category.transactions.count) transactions") = this is to desplay how meany transacoitns
                                Spacer()
                                
                                Text("\(categories.totalTransactionsForSelectedCategory(for: category)) AED")
                                    .foregroundColor(Color("Text2"))
                                    .padding()
                                
                            }  .padding(.leading,8)
                        )
                )
                .frame(width: UIScreen.main.bounds.width * 0.9, height: 73)
            
            
        }.background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
            
                .fill(.opacity(0.03))
                
                .frame(width: UIScreen.main.bounds.width * 0.95, height: 73)
          
            
        )

        .background(
            HStack{
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .foregroundColor(Color("Text2"))
                .cornerRadius(10)
                .padding(9)
                .frame(width:50, height: 50)
                .padding(.leading)
            
            Spacer()
            }
        )
    }
    
    func idForCategory() -> String {
        if let id = category.id?.uuidString {
            return id
        } else {
            DispatchQueue.main.async {
                self.fallbackIDCounter += 1
            }
            return "default" + String(fallbackIDCounter)
        }
        
    }
}

struct CiercleItem_Previews: PreviewProvider {
    @Namespace static var namespace
    
    static var dummyContext: NSManagedObjectContext = {
        let modelURL = Bundle.main.url(forResource: "Purple", withExtension: "momd")!
        let mom = NSManagedObjectModel(contentsOf: modelURL)!
        
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        let storeDescription = NSPersistentStoreDescription()
        storeDescription.type = NSInMemoryStoreType
        psc.addPersistentStore(with: storeDescription) { (storeDescription, error) in
            if let error = error {
                fatalError("Failed to setup in-memory CoreData stack for preview: \(error)")
            }
        }
        
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = psc
        return context
    }()
    
    static var sampleCategory: CategoryEntity = {
        let category = CategoryEntity(context: dummyContext)
        category.categoryIndex = 1
        category.progressbar = false
        category.limit = 20
        
        let transaction = FinancialTransactionEntity(context: dummyContext)
        transaction.title = "Transaction 1"
        transaction.amount = 200
        transaction.date = Date()
        
        category.addToTransactions(transaction)
        
        // Save the context so that the new category gets stored
        do {
            try dummyContext.save()
        } catch {
            fatalError("Failed to save dummy context: \(error)")
        }
        
        return category
    }()
    
    static var previews: some View {
        CircleItem(namespace: namespace, category: sampleCategory, show: .constant(true))
            .environmentObject(CategoryEnvironment(context: dummyContext))
            
    }
}
