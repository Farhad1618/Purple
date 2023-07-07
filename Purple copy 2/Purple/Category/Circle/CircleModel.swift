//
//  CircleModel.swift
//  Purple
//
//  Created by Farhad on 20/12/2022.
//
import CoreData

import SwiftUI

public struct P266_ViscosityCanvas: View {

    @State private var scale1: CGFloat = 1
    @State private var scale2: CGFloat = 1
    @State private var scale3: CGFloat = 1
    @State private var isFillMode: Bool = true
    
    public init() {}
    public var body: some View {
        ZStack {
            viscosityView(color: Color.purple, scale: $scale1)
          
     
                .blendMode(.screen)
           /*
            Toggle(isOn: $isFillMode) {
                EmptyView()
            }
            .labelsHidden()
            */
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    private func viscosityView(color: Color, scale: Binding<CGFloat>) -> some View {
        GeometryReader { geo in
            if isFillMode {
                ViscosityCanvas(color: color) {
                    circle(cnavasSize: geo.size, scale: scale)
                }
            } else {
                ViscosityCanvas(color: color, thresholdMin: 0.5, thresholdMax: 0.7) {
                    circle(cnavasSize: geo.size, scale: scale)
                }
            }
        }
    }
    
    @ViewBuilder
    private func circle(cnavasSize: CGSize, scale: Binding<CGFloat>) -> some View {
        let min = min(cnavasSize.width, cnavasSize.height) * 0.09
        let width: CGFloat = .random(in: min...(min * 2.6))
        let height: CGFloat = .random(in: min...(min * 2.6))
        
        ForEach(0..<60, id: \.self) { index in
            Circle()
                .frame(width: width, height: height)
                .scaleEffect(scale.wrappedValue * .random(in: 0.1..<1.5))
                .animation(Animation.easeInOut(duration: 3)
                    .repeatForever()
                    .speed(.random(in: 0.2...0.2))
                    .delay(.random(in: 0...2)), value: scale.wrappedValue)
                .position(CGPoint(x: .random(in: 0..<cnavasSize.width),
                                  y: .random(in: 0..<cnavasSize.height)))
                .tag(index)
        }
        .onAppear {
            scale.wrappedValue = scale.wrappedValue == 1.2 ? 1.0 : 1.2
        }
    }
}

fileprivate
struct ViscosityCanvas<Symbols: View> : View {
    
    let color: Color
    let thresholdMin: CGFloat
    let thresholdMax: CGFloat?
    let radius: CGFloat
    let symbols: () -> Symbols
    
    var body: some View {
        Canvas { context, size in
            if let thresholdMax = thresholdMax {
                context.addFilter(.alphaThreshold(min: thresholdMin, max: thresholdMax, color: color))
            } else {
                context.addFilter(.alphaThreshold(min: thresholdMin, color: color))
            }
            context.addFilter(.blur(radius: 12))
            context.drawLayer { ctx in
                for index in 0..<60 {
                    if let view = context.resolveSymbol(id: index) {
                        ctx.draw(view, at: CGPoint(x: size.width / 2, y: size.height / 2))
                    }
                }
            }
        } symbols: {
            symbols()
        }
    }
    
    init(color: Color, thresholdMin: CGFloat = 0.5, thresholdMax: CGFloat? = nil, radius: CGFloat = 12, @ViewBuilder symbols: @escaping () -> Symbols) {
        self.color = color
        self.thresholdMin = thresholdMin
        self.thresholdMax = thresholdMax
        self.radius = radius
        self.symbols = symbols
    }
}

struct P266_ViscosityCanvas_Previews: PreviewProvider {
    static var previews: some View {
        P266_ViscosityCanvas()
    }
}
/*
 
 import SwiftUI
 import CoreData

 struct CircleModel: View {
     var namespace: Namespace.ID
     @Binding var show: Bool
     let category: CategoryEntity
     @State private var transactionName = ""
     @State private var transactionAmountText = ""
     @State private var showTransactionPopup = false
     @Environment(\.managedObjectContext) var managedObjectContext
     @State var selectedCategory: CategoryEntity?

     var body: some View {
         ZStack {
             VStack {
                 Spacer()

                 ScrollView {
                     VStack(alignment: .leading, spacing: 30) {
                         ForEach(Array(category.financialTransactions?.allObjects as? [FinancialTransactionEntity] ?? []), id: \.self) { transaction in
                             VStack(alignment: .leading) {
                                 Text(transaction.title ?? "")
                                     .font(.headline)
                                 Text("\(transaction.amount)")
                                 Text(self.formatDate(date: transaction.date ?? Date()))
                             }
                         }
                         .padding()
                         .background(
                             Rectangle()
                                 .fill(.ultraThinMaterial)
                                 .mask(RoundedRectangle(cornerRadius: 30, style: .continuous)))
                         .frame(width: .infinity, height: .infinity)
                     }
                 }

                 Button(action: {
                     withAnimation(.easeInOut(duration: 0.3)) {
                         showTransactionPopup.toggle()
                     }
                 }) {
                     Image(systemName: "plus")
                         .resizable()
                         .frame(width: 24, height: 24)
                         .foregroundColor(.white)
                         .padding()
                         .background(Color.blue)
                         .clipShape(Circle())
                 }
                 .padding(.bottom)
             }
             .blur(radius: showTransactionPopup ? 5 : 0)

             if showTransactionPopup {
                 VStack {
                     TextField("Amount", text: $transactionAmountText)
                         .keyboardType(.numberPad)
                         .padding()
                         .background(Color.gray.opacity(0.2))
                         .cornerRadius(8)

                     TextField("Name", text: $transactionName)
                         .padding()
                         .background(Color.gray.opacity(0.2))
                         .cornerRadius(8)

                     Button("Done") {
                         if let transactionAmount = Int64(transactionAmountText), !transactionName.isEmpty {
                             let newTransaction = FinancialTransactionEntity(context: managedObjectContext)
                             newTransaction.title = transactionName
                             newTransaction.amount = transactionAmount
                             newTransaction.date = Date()
                             newTransaction.category = selectedCategory

                             transactionName = ""
                             transactionAmountText = ""
                             do {
                                 try managedObjectContext.save()
                             } catch {
                                 print("Failed to save transaction: \(error)")
                             }
                         }

                         withAnimation(.easeInOut(duration: 0.3)) {
                             showTransactionPopup = false
                         }
                     }

                     .padding()
                     .foregroundColor(.white)
                     .background(Color.blue)
                     .cornerRadius(8)
                 }
                 .padding()
                 .background(Color.white)
                 .cornerRadius(16)
                 .shadow(radius: 10)
                 .transition(.move(edge: .bottom))
             }
         }
     }

     func formatDate(date: Date) -> String {
         let formatter = DateFormatter()
         formatter.dateFormat = "MM/dd/yyyy"
         return formatter.string(from: date)
     }
 }

 struct CircleModel_Previews: PreviewProvider {
     @Namespace static var namespace

     static var previews: some View {
         let context = CoreDataStack.shared.viewContext
         let sampleCategory = CategoryEntity(context: context)
         sampleCategory.id = UUID()
         sampleCategory.categoryIndex = 1
         sampleCategory.limit = 100
         sampleCategory.progressbar = true
         
         // Add sample transaction
         let sampleTransaction = FinancialTransactionEntity(context: context)
         sampleTransaction.title = "Sample Transaction"
         sampleTransaction.amount = 50
         sampleTransaction.date = Date()
         sampleTransaction.category = sampleCategory
         sampleCategory.addToTransactions(sampleTransaction)
         
         do {
             try context.save()
         } catch {
             print("Failed to save context: \(error)")
         }
         
         return CircleModel(namespace: namespace, show: .constant(true), selectedCategory: sampleCategory)
             .environment(\.managedObjectContext, context)
     }
 }

 */
