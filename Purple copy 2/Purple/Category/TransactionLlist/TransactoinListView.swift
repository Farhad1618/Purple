//
//  TransactoinListView.swift
//  Purple
//
//  Created by Farhad on 10/06/2023.
//


import SwiftUI
import AxisContribution
struct CategoryTransactionsView: View {
    var selectedCategory: CategoryEntity
    @State private var constant: ACConstant = .init(axisMode: .horizontal)
    @State private var rowSize: CGFloat = 11
    @State private var rowImageName: String = ""
    
    var body: some View {
        VStack {
            AxisContribution(constant: constant, source: getTransactionData()) { indexSet, data in
                Rectangle()
                    .fill(Color.secondary.opacity(0.8))
                    .frame(width: rowSize, height: rowSize)
                    .cornerRadius(2)
            } foreground: { indexSet, data in
                Rectangle()
                    .fill(Color.purple)
                    .frame(width: rowSize, height: rowSize)
                    .border(Color.white.opacity(0.2), width: 1)
                    .cornerRadius(2)
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(lineWidth: 1)
                    .fill(Color.secondary.opacity(0.6))
                    .opacity(0.5)
            )
            .frame(maxWidth: 833, maxHeight: 833)
        }
        .padding()
    }
    private func getTransactionData() -> [Date: ACData] {
        var transactionData: [Date: ACData] = [:]
        let transactions = selectedCategory.transactions?.allObjects as? [FinancialTransactionEntity] ?? []
        for transaction in transactions {
            guard let date = transaction.date else { continue }
            if let data = transactionData[date] {
                // If there is already an ACData object for this date, increment the count
                data.count += 1
            } else {
                // If there is no ACData object for this date, create one with a count of 1
                let data = ACData(date: date, count: 1)
                transactionData[date] = data
            }
        }
        print(transactionData) // Add this line
        return transactionData
    }



}

struct CategoryTransactionsView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let category = CategoryEntity(context: context)
        for i in 0..<10 {
            let transaction = FinancialTransactionEntity(context: context)
            transaction.date = Calendar.current.date(byAdding: .day, value: i, to: Date()) // add i days to the current date
            transaction.amount = Int64.random(in: 1...100)
            category.addToTransactions(transaction)
        }
        return CategoryTransactionsView(selectedCategory: category)
            .environment(\.managedObjectContext, context)
    }
}

