//
//  CircleView.swift
//  Purple
//
//  Created by Farhad on 20/12/2022.
//

import SwiftUI

struct CircleView: View {
    
    @State private var amount: String = ""
       @State private var name: String = ""
       @State private var transactions: [FinancialTransaction] = []
    
    var body: some View {
        VStack {
            HStack {
                TextField("Amount", text: $amount)
                TextField("Name", text: $name)
                Button(action: {
                    if let amount = Int(self.amount), !self.name.isEmpty {
                        let transaction = FinancialTransaction(amount: amount, name: self.name, date: Date())
                        self.transactions.append(transaction)
                    }
                }) {
                    Text("Add Transaction")
                }
            }
            List {
                ForEach(transactions) { transaction in
                    VStack(alignment: .leading) {
                        Text(transaction.name)
                            .font(.headline)
                        Text("\(transaction.amount)")
                        Text(self.formatDate(date: transaction.date))
                    }
                }
            }
            Text("Total: \(transactions.reduce(0, { $0 + $1.amount }))")
                .font(.headline)
        }
    }

    func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
    }
}


struct CircleView_Previews: PreviewProvider {
    static var previews: some View {
        CircleView()
    }
}


