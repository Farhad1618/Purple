//
//  TransactionView.swift
//  Purple
//
//  Created by Farhad on 20/12/2022.
//


import SwiftUI
import CoreData
struct TransactionView: View {
    @State private var amount: String = ""
    @State private var name: String = ""
    @EnvironmentObject var transactions: TransactionsEnvironment
    @EnvironmentObject var categories: CategoryEnvironment
    @Binding var selectedCategory: CategoryEntity

    var body: some View {
        VStack {
            HStack {
                // add new transaction
                TextField("Amount", text: $amount)
                TextField("Name", text: $name)
                Button(action: {
                    if let amount = Int64(self.amount), !self.name.isEmpty {
                        let newTransaction = FinancialTransactionEntity(context: categories.context)
                        newTransaction.title = self.name
                        newTransaction.amount = amount
                        newTransaction.date = Date()

                        categories.addTransactionToCategory(newTransaction, to: selectedCategory)
                    }
                }) {
                    Text("Add Transaction")
                }
            }

            // display the transactions for the selected category
            List {
                ForEach(Array(selectedCategory.transactions as? Set<FinancialTransactionEntity> ?? []), id: \.self) { transaction in
                    VStack(alignment: .leading) {
                        Text(transaction.title ?? "")
                            .font(.headline)
                        Text("\(transaction.amount)")
                        Text(self.formatDate(date: transaction.date ?? Date()))
                    }
                }
            }

            // total transactions for the selected category
            Text("Total: \(selectedCategory.transactions?.reduce(0, { $0 + (($1 as? FinancialTransactionEntity)?.amount ?? 0) }) ?? 0)")
                .font(.headline)

        }
    }

    func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
    }
}

struct TransactionView_Previews: PreviewProvider {
    static var previews: some View {
        let context = CoreDataStack.shared.viewContext
        let selectedCategory = CategoryEntity(context: context)
        selectedCategory.categoryIndex = 1
        selectedCategory.progressbar = false
        selectedCategory.limit = 23

        return TransactionView(selectedCategory: .constant(selectedCategory))
            .environmentObject(TransactionsEnvironment(context: context))
            .environmentObject(CategoryEnvironment(context: context))
            .environment(\.managedObjectContext, context)
    }
}
