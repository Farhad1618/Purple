//
//  Hierarchy.swift
//  Purple
//
//  Created by Farhad on 03/01/2023.
//


import Foundation
import SwiftUI
import Combine
import CoreData

let predefinedCategories = ["Accessories", "Banking", "Beauty Services", "Car", "Cell Phone", "Childcare", "Cleaning and Home Maintenance Services", "Clothing", "Doctor Visits", "Eat out", "Electricity", "Entertainment", "Financial Services and Fees", "Gas", "Garden Services", "Gifts and Special Occasions", "Groceries", "Gym", "Haircuts", "Health Insurance", "Home Improvements", "Internet", "Jewelry and Watches", "Makup", "Medicine", "Personal Care Products", "Personal Hygiene Products", "Pet Care and Grooming Services", "Pet Food and Supplies", "Rent", "School", "Transportation", "Water"]

 enum TimeFrame2: String, Codable, CaseIterable {
    case none = "Never"
    case day = "1"
    case week = "7"
    case month = "30"
    case year = "360"
}

extension FinancialTransactionEntity {
    var recurringFrequencyEnum: TimeFrame2? {
        get {
            return TimeFrame2(rawValue: self.recurringFrequencyRaw ?? "")
        }
        set {
            self.recurringFrequencyRaw = newValue?.rawValue
        }
    }
}
enum LimitTimeFrame: Int64, CaseIterable {
    case Never = 0
    case daily
    case weekly
    case monthly
    case yearly
}


extension CategoryEntity {
  
    var limitTimeFrame: LimitTimeFrame {
        get { return LimitTimeFrame(rawValue: limitTimeFrameRaw) ?? .Never }
        set { limitTimeFrameRaw = newValue.rawValue }
    }
}

// MARK: DateCategories
class DateCategoriesEnvironment: ObservableObject {
    var context: NSManagedObjectContext
    @Published var dateCategory: [DateEntity] = []
    @Published var selectedIndex: Int = 0
    
    init(context: NSManagedObjectContext) {
        self.context = context
        fetchDateEntity()
    }
    
    
    func fetchDateEntity() {
        let fetchRequest = NSFetchRequest<DateEntity>(entityName: "DateEntity")
        
        do {
            let result = try context.fetch(fetchRequest)
            DispatchQueue.main.async {
                self.dateCategory = result
            }
        } catch let error {
            print("Failed to fetch transactions: \(error)")
        }
    }
}


    // MARK: Category
class CategoryEnvironment: ObservableObject {
    var context: NSManagedObjectContext
    @Published var categories: [CategoryEntity] = []
    @Published var selectedTimeFrame: TimeFrame2 = .day
    @Published var totalTransactionsPast7Days: Int = 0
    @Published var totalTransactionsCurrentMonth: Int = 0
    @Published var transactionsForSelectedCategory: [FinancialTransactionEntity] = []

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchCategories(for: Date())
    }
    
    func fetchTransactions(for category: CategoryEntity) {
        transactionsForSelectedCategory = category.transactions?.allObjects as? [FinancialTransactionEntity] ?? []
    }

    var datesForPicker: [Date] {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .month, value: -1, to: Date())!
        let endDate = Date()

        return dates(from: startDate, to: endDate)
    }

    func dates(from startDate: Date, to endDate: Date) -> [Date] {
        var dates = [Date]()
        var currentDate = startDate

        while currentDate <= endDate {
            dates.append(currentDate)
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }

        return dates
    }

    func calculateTotalTransactionsPast7Days() {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        totalTransactionsPast7Days = categories
            .flatMap { $0.transactions?.allObjects as? [FinancialTransactionEntity] ?? [] }
            .filter { transaction in
                guard let date = transaction.date else { return false }
                return date.compare(sevenDaysAgo) != .orderedAscending
            }
            .reduce(0) { $0 + Int($1.amount) } // Use $1 to refer to the current transaction
    }

    func calculateTotalTransactionsCurrentMonth() {
        let now = Date()
        let startOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: now))!
        let endOfMonth = Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        totalTransactionsCurrentMonth = categories
            .flatMap { $0.transactions?.allObjects as? [FinancialTransactionEntity] ?? [] }
            .filter { transaction in
                guard let date = transaction.date else { return false }
                return date.compare(startOfMonth) != .orderedAscending && date.compare(endOfMonth) != .orderedDescending
            }
            .reduce(0) { $0 + Int($1.amount) } // Use $1 to refer to the current transaction
    }

    func addTransactionToCategory(_ transaction: FinancialTransactionEntity, to category: CategoryEntity) {
        category.addToTransactions(transaction)

        do {
            try context.save()
        } catch {
            print("Failed to save context after adding transaction to category: \(error)")
        }

        fetchCategories(for: Date())
    }
// MARK: Fetch Categories
    func fetchCategories(for date: Date) {
        let request: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()

        do {
            categories = try context.fetch(request)
            categories = categories.filter { category in
                let transactions = category.transactions?.allObjects as? [FinancialTransactionEntity] ?? []
                return category.progressbar || transactions.contains { transaction in
                    guard let transactionDate = transaction.date else { return false }
                    return Calendar.current.isDate(transactionDate, inSameDayAs: date)
                }
            }
            calculateTotalTransactionsPast7Days()
            calculateTotalTransactionsCurrentMonth()
        } catch let error {
            print("Failed to fetch categories: \(error)")
        }
    }

    func deleteCategory(_ category: CategoryEntity) {
        // Delete all transactions associated with the category
        if let transactions = category.transactions {
            for transaction in transactions {
                context.delete(transaction as! NSManagedObject)
            }
        }

        // Delete the category
        context.delete(category)

        // Save the changes
        do {
            try context.save()
        } catch {
            print("Failed to delete category: \(error)")
        }

        // Fetch the categories again to update the UI
        fetchCategories(for: Date())
    }


    var totalTransactions: Int64 {
        categories.flatMap { $0.transactions?.allObjects as? [FinancialTransactionEntity] ?? [] }
            .reduce(0) { $0 + Int64($1.amount) }
    }

    func totalTransactionsForSelectedCategory(for category: CategoryEntity) -> Int {
        return category.transactions?.count ?? 0
    }

    func processRecurringTransactions() {
        let currentDate = Date()
        for category in categories {
            guard let transactions = category.transactions?.allObjects as? [FinancialTransactionEntity] else { continue }
            for transaction in transactions {
                if transaction.isRecurring, let frequency = transaction.recurringFrequencyEnum, let transactionDate = transaction.date {
                    let calendar = Calendar.current
                    switch frequency {
                    case .day:
                        if calendar.isDate(transactionDate, inSameDayAs: currentDate) {
                            createNewTransaction(for: transaction, addTo: category, currentDate: currentDate, adding: .day, value: 1)
                        }
                    case .week:
                        if calendar.dateComponents([.day], from: transactionDate, to: currentDate).day! >= 7 {
                            createNewTransaction(for: transaction, addTo: category, currentDate: currentDate, adding: .day, value: 7)
                        }
                    case .month:
                        if calendar.dateComponents([.month], from: transactionDate, to: currentDate).month! >= 1 {
                            createNewTransaction(for: transaction, addTo: category, currentDate: currentDate, adding: .month, value: 1)
                        }
                    case .year:
                        if calendar.dateComponents([.year], from: transactionDate, to: currentDate).year! > 0 {
                            createNewTransaction(for: transaction, addTo: category, currentDate: currentDate, adding: .year, value: 1)
                        }
                    case .none:
                        continue
                    }
                }
            }
        }
    }

    private func createNewTransaction(for transaction: FinancialTransactionEntity, addTo category: CategoryEntity, currentDate: Date, adding component: Calendar.Component, value: Int) {
        let newTransaction = FinancialTransactionEntity(context: context)
        newTransaction.title = transaction.title
        newTransaction.amount = transaction.amount
        newTransaction.date = Calendar.current.date(byAdding: component, value: value, to: currentDate)
        newTransaction.isRecurring = transaction.isRecurring
        newTransaction.recurringFrequencyRaw = transaction.recurringFrequencyEnum?.rawValue
        category.addToTransactions(newTransaction)
    }

    func createOrUpdateCategory(withIndex index: Int, showProgressBar: Bool, limit: Int64, limitTimeFrame: LimitTimeFrame, transaction: FinancialTransactionEntity? = nil) {
        let fetchRequest: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "categoryIndex = %d", index)

        do {
            let results = try context.fetch(fetchRequest)
            if let category = results.first {
                category.progressbar = showProgressBar
                category.limit = limit
                category.limitTimeFrame = limitTimeFrame

                if let transaction = transaction {
                    category.addToTransactions(transaction)
                }
            } else {
                let newCategory = CategoryEntity(context: context)
                newCategory.id = UUID()
                newCategory.categoryIndex = Int64(index)
                newCategory.progressbar = showProgressBar
                newCategory.limit = limit
                newCategory.limitTimeFrame = limitTimeFrame

                if let transaction = transaction {
                    newCategory.addToTransactions(transaction)
                }
            }

            try context.save()
            fetchCategories(for: Date())
        } catch {
            print("Failed to fetch or save category: \(error)")
        }
    }

    func deleteAllCategories() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CategoryEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            try context.save()
            fetchCategories(for: Date())
        } catch {
            print ("There was an error")
        }
    }
}

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
}


        

    

    
    //  MARK: TransactionsEnvironment
class TransactionsEnvironment: ObservableObject {
    var context: NSManagedObjectContext
    @Published var transactionsForSelectedDate: [FinancialTransactionEntity] = []
    @Published var transactions: [FinancialTransactionEntity] = []
    @Published var selectedDate: Date {
        didSet {
            fetchTransactionsforSelectedDate(for: selectedDate)
        }
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.selectedDate = Date() // Initialize selectedDate with the current date
        fetchTransactionsforSelectedDate(for: selectedDate)
    }

        func fetchTransactions() {
            let fetchRequest = NSFetchRequest<FinancialTransactionEntity>(entityName: "FinancialTransactionEntity")
            fetchRequest.predicate = NSPredicate(format: "(date >= %@) AND (date < %@)", argumentArray: [Date().startOfDay, Date().startOfDay.addingTimeInterval(86400)])// Value of type 'Date' has no member 'startOfDay'
            
            do {
                let result = try context.fetch(fetchRequest)
                transactions = result
            } catch let error {
                print("Failed to fetch transactions: \(error)")
            }
        }
    
    //MARK: fetchTransactionsforSelectedDate
    func fetchTransactionsforSelectedDate(for date: Date) {
        let fetchRequest = NSFetchRequest<FinancialTransactionEntity>(entityName: "FinancialTransactionEntity")
        fetchRequest.predicate = NSPredicate(format: "(date >= %@) AND (date < %@)", argumentArray: [date.startOfDay, date.startOfDay.addingTimeInterval(86400)])// Value of type 'Date' has no member 'startOfDay'
        
        do {
            let result = try context.fetch(fetchRequest)
            DispatchQueue.main.async {
                self.transactions = result
            }
        } catch let error {
            print("Failed to fetch transactions: \(error)")
        }
    }


      
     
        
    // Add new transaction
    func addTransaction(title: String, amount: Int64, date: Date, isRecurring: Bool, recurringFrequency: TimeFrame2) {
        let newTransaction = FinancialTransactionEntity(context: context)
        newTransaction.title = title
        newTransaction.amount = amount
        newTransaction.date = date
        newTransaction.isRecurring = isRecurring
        newTransaction.recurringFrequencyRaw = recurringFrequency.rawValue
        newTransaction.id = UUID()
        do {
            try context.save()
            fetchTransactionsforSelectedDate(for: selectedDate) // Fetch transactions after adding a new one
        } catch let error {
            print("Failed to save new transaction: \(error)")
        }
    }

    // Update a transaction
    func updateTransaction(_ transaction: FinancialTransactionEntity, title: String, amount: Int64, date: Date, isRecurring: Bool, recurringFrequency: TimeFrame2) {
        transaction.title = title
        transaction.amount = amount
        transaction.date = date
        transaction.isRecurring = isRecurring
        transaction.recurringFrequencyRaw = recurringFrequency.rawValue
        do {
            try context.save()
            fetchTransactionsforSelectedDate(for: selectedDate) // Fetch transactions after updating
        } catch let error {
            print("Failed to update transaction: \(error)")
        }
    }

        // Delete a transaction
        func deleteTransaction(_ transaction: FinancialTransactionEntity) {
            context.delete(transaction)
            do {
                try context.save()
                fetchTransactions() // Refresh the list of transactions after deleting
            } catch let error {
                print("Failed to delete transaction: \(error)")
            }
        }
        
 
    }
    
    class CoreDataStack {
        static let shared = CoreDataStack()
        
        let container: NSPersistentContainer
        
        var viewContext: NSManagedObjectContext {
            return container.viewContext
        }
        
        private init() {
            container = NSPersistentContainer(name: "Purple")
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
        }
    }



/*
// for each dateCategory there can be one or more Category and for each Category there can be one or more FinancialTransaction
struct DateCategory: Codable {
    let date: Date
    var categories: [Category]
}

enum TimeFrame: String, CaseIterable {
    case day, week, month, year
}


//
// MARK: Category
//
 
let predefinedCategories = ["Accessories", "Banking", "Beauty Services", "Car", "Cell Phone", "Childcare", "Cleaning and Home Maintenance Services", "Clothing", "Doctor Visits", "Eat out", "Electricity", "Entertainment", "Financial Services and Fees", "Gas", "Garden Services", "Gifts and Special Occasions", "Groceries", "Gym", "Haircuts", "Health Insurance", "Home Improvements", "Internet", "Jewelry and Watches", "Makup", "Medicine", "Personal Care Products", "Personal Hygiene Products", "Pet Care and Grooming Services", "Pet Food and Supplies", "Rent", "School", "Transportation", "Water"]


class Category: Identifiable, Codable, Hashable {
    var id = UUID()
    var category Index: Int
    var transactions: [FinancialTransaction]
    var progressbar: Bool
    var limite: Int
    var totalTransactions: Int {
        Int(transactions.reduce(0) { $0 + $1.amount })
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    required init(categoryIndex: Int, transactions: [FinancialTransaction], progressbar: Bool, limit: Int) {
        self.categoryIndex = categoryIndex
        self.transactions = transactions
        self.progressbar = progressbar
        self.limite = limit
    }

    enum CodingKeys: String, CodingKey {
        case id
        case categoryIndex
        case transactions
        case progressbar
        case limite
        case totalTransactions
    }
    
    convenience required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let categoryIndex = try container.decode(Int.self, forKey: .categoryIndex)
        let transactions = try container.decode([FinancialTransaction].self, forKey: .transactions)
        let progressbar = try container.decode(Bool.self, forKey: .progressbar)
        let limite = try container.decode(Int.self, forKey: .limite)

        self.init(categoryIndex: categoryIndex, transactions: transactions, progressbar: progressbar, limit: limite)
        self.id = id
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(categoryIndex, forKey: .categoryIndex)
        try container.encode(transactions, forKey: .transactions)
        try container.encode(progressbar, forKey: .progressbar)
        try container.encode(limite, forKey: .limite)
        try container.encode(totalTransactions, forKey: .totalTransactions)
    }

}


class CategoryEnvironment: ObservableObject {
    @Published var categories: [Category] = []
    @Published var selectedTimeFrame: TimeFrame = .day
    private var timer: Timer?
     
    
    var totalTransactions: Int {
        categories.reduce(0) { $0 + $1.totalTransactions }
    }
    func processRecurringTransactions() {
          let currentDate = Date()
          for category in categories {
              for transaction in category.transactions {
                  if transaction.isRecurring, let frequency = transaction.recurringFrequency {
                      switch frequency {
                      case .day:
                          if Calendar.current.isDate(transaction.date, inSameDayAs: currentDate) {
                              let newTransaction = FinancialTransaction(title: transaction.title, amount: transaction.amount, date: Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!, isRecurring: transaction.isRecurring, recurringFrequency: transaction.recurringFrequency)
                              category.transactions.append(newTransaction)
                          }
                      case .week:
                          if Calendar.current.dateComponents([.day], from: transaction.date, to: currentDate).day! % 7 == 0 {
                              let newTransaction = FinancialTransaction(title: transaction.title, amount: transaction.amount, date: Calendar.current.date(byAdding: .day, value: 7, to: currentDate)!, isRecurring: transaction.isRecurring, recurringFrequency: transaction.recurringFrequency)
                              category.transactions.append(newTransaction)
                          }
                      case .month:
                          if Calendar.current.dateComponents([.day], from: transaction.date, to: currentDate).day! % 30 == 0 {
                              let newTransaction = FinancialTransaction(title: transaction.title, amount: transaction.amount, date: Calendar.current.date(byAdding: .month, value: 1, to: currentDate)!, isRecurring: transaction.isRecurring, recurringFrequency: transaction.recurringFrequency)
                              category.transactions.append(newTransaction)
                          }
                      case .year:
                          if Calendar.current.dateComponents([.year], from: transaction.date, to: currentDate).year! > 0 {
                              let newTransaction = FinancialTransaction(title: transaction.title, amount: transaction.amount, date: Calendar.current.date(byAdding: .year, value: 1, to: currentDate)!, isRecurring: transaction.isRecurring, recurringFrequency: transaction.recurringFrequency)
                              category.transactions.append(newTransaction)
                          }
                      case .none:
                          continue
                      }
                  }
              }
          }
      }

    func generateTestData() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        let transactiono = [
            FinancialTransaction(title: "Grocery", amount: 50, date: dateFormatter.date(from: "2023/05/01")!),
            FinancialTransaction(title: "Lunch", amount: 30, date: dateFormatter.date(from: "2023/05/02")!),
            FinancialTransaction(title: "Dinner", amount: 40, date: dateFormatter.date(from: "2023/05/03")!),
            FinancialTransaction(title: "Snack", amount: 10, date: dateFormatter.date(from: "2023/05/04")!),
            FinancialTransaction(title: "Breakfast", amount: 20, date: dateFormatter.date(from: "2023/05/05")!),
            FinancialTransaction(title: "Dessert", amount: 15, date: dateFormatter.date(from: "2023/05/06")!),
            FinancialTransaction(title: "Coffee", amount: 5, date: dateFormatter.date(from: "2023/05/07")!)
        ]
        
        let category = Category(categoryIndex: 0, transactions: transactiono, progressbar: true, limit: 300)
        self.categories.append(category)
    }
    init() {
           generateTestData()
           setupTimer()
       }

       private func setupTimer() {
           timer = Timer.scheduledTimer(withTimeInterval: 86400, repeats: true) { [weak self] _ in
               self?.processRecurringTransactions()
           }
       }

       deinit {
           timer?.invalidate()
       }


}

extension Category: Equatable {
    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.id == rhs.id
    }
}

//
// MARK: FinancialTransaction
//

enum TimeFrame2: String, Codable, CaseIterable {
    case day = "Every day"
    case week = "Every 7 days"
    case month = "Every 30 days"
    case year = "Every year"
    case none = "None"
}


struct FinancialTransaction: Identifiable, Codable {
    var id = UUID()
    var title: String
    var amount: Int
    var date: Date
    var isRecurring: Bool // New property
    var recurringFrequency: TimeFrame2? // New property

    init(title: String, amount: Int, date: Date, isRecurring: Bool = false, recurringFrequency: TimeFrame2? = nil) {
        self.title = title
        self.amount = amount
        self.date = date
        self.isRecurring = isRecurring
        self.recurringFrequency = recurringFrequency
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case amount
        case date
        case isRecurring
        case recurringFrequency
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let title = try container.decode(String.self, forKey: .title)
        let amount = try container.decode(Int.self, forKey: .amount)
        let date = try container.decode(Date.self, forKey: .date)
        let isRecurring = try container.decode(Bool.self, forKey: .isRecurring)
        let recurringFrequencyString = try container.decode(String?.self, forKey: .recurringFrequency)
        let recurringFrequency = recurringFrequencyString != nil ? TimeFrame2(rawValue: recurringFrequencyString!) : nil

        self.init(title: title, amount: amount, date: date, isRecurring: isRecurring, recurringFrequency: recurringFrequency)
        self.id = id
    }


    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(amount, forKey: .amount)
        try container.encode(date, forKey: .date)
        try container.encode(isRecurring, forKey: .isRecurring)
        let recurringFrequencyString = recurringFrequency?.rawValue
        try container.encode(recurringFrequencyString, forKey: .recurringFrequency)
    }

}

extension FinancialTransaction: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(amount)
        hasher.combine(date)
    }

    static func ==(lhs: FinancialTransaction, rhs: FinancialTransaction) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title && lhs.amount == rhs.amount && lhs.date == rhs.date
    }
}



class TransactionsEnvironment: ObservableObject {
    @Published var transactions: [FinancialTransaction] = []


}
// MARK: Filter
 */
