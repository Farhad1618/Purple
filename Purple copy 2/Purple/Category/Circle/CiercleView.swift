//
//  CiercleItem.swift
//  Purple
//
//  Created by Farhad on 23/01/2023.
//

import SwiftUI
import Charts
import CoreData

struct FilteredTransaction: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let amount: Int
}


struct CiercleView: View {
    
    var namespace: Namespace.ID
    @Binding var show: Bool
    @State var category: CategoryEntity
    @State var appear = [false,false,false]
    @State var viewState: CGSize = .zero
    @State private var scrollViewContentOffset = CGFloat(0)
    @State private var transactionName = ""
    @State private var transactionAmountText = ""
    @State private var showTransactionPopup = false
    @EnvironmentObject var transactions: TransactionsEnvironment
    @EnvironmentObject var categories: CategoryEnvironment
    @State var selectedCategory: CategoryEntity?
    @EnvironmentObject var model: Model
    @State private var selectedTimeFrame2: TimeFrame2 = .none
    @State private var showingDeleteConfirmation = false
    @State private var progressBarState: Bool = false
    @State private var showingEditSheet = false

    enum TimeFrame: String, CaseIterable {
        case day, week, month, year
    }
    
    @State private var selectedTimeFrame: TimeFrame = .day// Invalid redeclaration of 'selectedTimeFrame'
    
    // chart data
    @State private var dailyTransactions: [FilteredTransaction] = []
    @State private var weeklyTransactions: [FilteredTransaction] = []
    @State private var monthlyTransactions: [FilteredTransaction] = []
    @State private var yearlyTransactions: [FilteredTransaction] = []
    
    
    var body: some View {
        ZStack(alignment: .bottom){
            ScrollView {
                
                //
                cover
                EditCategory
                    .padding(.trailing,150)
                    .offset(y:-90)
                VStack(alignment: .leading){
                    Text("You have spent a grand total of 4000 AED")
                        .foregroundColor(.secondary)
                        .offset(y:-60)
                        .padding(.trailing)
                }
                if let selectedCategory = selectedCategory {
                    CategoryTransactionsView(selectedCategory: selectedCategory)
                    
                } else {
                    // Placeholder content here
                    Text("No category selected")
                }

                TimeFrameButton
                content
                 
                // .offset(y: 120)
                    .padding(.bottom, 200)
                    .opacity(appear[2] ? 1 : 0)
                
        /*
                if category.progressbar == true {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.clear)
                        .frame(width: 420, height: 63)
                        .overlay(
                            ProgressBare(total: Double(category.limite), current: Double(category.totalTransactions))
                                .id("progressbar")
                                .matchedGeometryEffect(id: "progressBare\(category.id)", in: namespace)
                        )
                    
                }
                */
                Button(action: {
                    showingDeleteConfirmation = true
                }) {
                    Text("Delete Category")
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10,style: .continuous)
                                .fill(Color.red)
                        )
                        
                        .padding(.bottom,150)
                    
                }
                .sheet(isPresented: $showingDeleteConfirmation) {
                    VStack {
                        Text("Are you sure you want to delete this category?")
                            .font(.title)
                            .padding()

                        HStack {
                            Button(action: {
                                categories.deleteCategory(category)
                                showingDeleteConfirmation = false
                            }) {
                                Text("Yes, delete it")
                                    .foregroundColor(.red)
                            }
                            .padding()

                            Button(action: {
                                showingDeleteConfirmation = false
                            }) {
                                Text("No, keep it")
                                    .foregroundColor(.blue)
                            }
                            .padding()
                        }
                    }
                }

            }.onAppear {
                updateTransactions()
            }
            .mask(RoundedRectangle(cornerRadius: viewState.width / 3, style: .continuous))
            .shadow(color: .black.opacity(0.3), radius: 30, x: 0, y: 10)
            .scaleEffect(viewState.width / -500 + 1)
            .background(.black.opacity(viewState.width / 500))
            .background(.ultraThinMaterial)
            .gesture(
                DragGesture()
                    .onChanged { value in
                    
                        guard value.translation.width > 0 else { return }// fixes the right part
                        if value.startLocation.x < 100 {
                            viewState = value.translation
                        }
                        
                    }
                    .onEnded { value in
                        if viewState.width > 80 {
                            withAnimation(.spring(response: 0.5,dampingFraction:0.9 ,blendDuration: 0.5)) {
                                show.toggle()
                                // model.showDetail.toggle()
                            }
                        }
                        withAnimation(.spring(response: 0.5,dampingFraction:0.9 ,blendDuration: 0.5)) {
                            viewState = .zero
                        } } )
            .ignoresSafeArea()
            
            //
            dismissButton_and_addButton
            
             //
           
        }.onAppear{
            withAnimation(.spring(response: 0.5,dampingFraction:0.9 ,blendDuration: 0.5)) {
                appear[0] = true
            }
            withAnimation(.spring(response: 0.5,dampingFraction:0.9 ,blendDuration: 0.5)) {
                appear[1] = true
            }
            withAnimation(.spring(response: 0.5,dampingFraction:0.9 ,blendDuration: 0.5)) {
                appear[2] = true
            }
            
        }
        .onChange(of: show) { newValue in
            appear[0] = false
            appear[1] = false
            appear[2] = false
        }
        .background(
            Rectangle()
                .fill(Color.clear)
                .mask(RoundedRectangle(cornerRadius: 30, style: .continuous)))
        .ignoresSafeArea()
    }
    
    // MARK: transactionPopup
    private var transactionPopup: some View {
        ZStack{
      
            VStack(alignment: .leading){
                    
                    TextField("Name", text: $transactionName)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(8)
                        .frame(width: 200,height: 80)
                        
                    TextField("Amount", text: $transactionAmountText)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(8)
                        .frame(width: 200,height: 80)
                
                TimeFrame2Button
                    Button("Done") {
                        createNewTransaction()
                    }
                    
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.purple)
                    .cornerRadius(8)
                    
                }
                .padding()
                .background(Color.clear)
                .cornerRadius(16)
                .shadow(radius: 10)
                .transition(.move(edge: .bottom))
            
        } .zIndex(1)
    }
    private var TimeFrame2Button: some View {
        let buttonWidth: CGFloat = 70
        let buttonHeight: CGFloat = 66

        return ZStack {
            HStack {
                ForEach(TimeFrame2.allCases, id: \.self) { timeFrame in
                    Button(action: {
                        withAnimation(.spring(response: 0.5,dampingFraction:0.9 ,blendDuration: 0.5)) {
                            selectedTimeFrame2 = timeFrame
                        }
                    }) {
                        VStack(spacing: 0) {
                            Text(timeFrame.rawValue)
                                .frame(width: buttonWidth, height: 29)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .foregroundColor(selectedTimeFrame2 == timeFrame ? .primary : .secondary)
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 15)
            .frame(width: 375, height: buttonHeight, alignment: .top)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .background(
                ForEach(TimeFrame2.allCases.indices, id: \.self) { index in
                    if selectedTimeFrame2.rawValue == TimeFrame2.allCases[index].rawValue {
                        Circle().fill(Color.purple).frame(width: 100)
                            .offset(x: CGFloat(index - TimeFrame2.allCases.count / 2) * 100)
                            .padding(.leading,100)
                        Rectangle()
                            .fill(Color.purple)
                            .frame(width: 28, height: 5)
                            .cornerRadius(3)
                            .frame(width: buttonWidth)
                            .frame(maxHeight: .infinity, alignment: .top)
                            .offset(x: CGFloat(index - TimeFrame2.allCases.count / 2) * buttonWidth)
                    }
                }
            )
        }
    }

    // MARK: dismissButton&addButton
    private var dismissButton_and_addButton: some View {// error:Function declares an opaque return type, but has no return statements in its body from which to infer an underlying type
        ZStack{
            /*
            Button {
                withAnimation(.spring(response: 0.5,dampingFraction:0.9 ,blendDuration: 0.5)) {
                    show.toggle()
                    //   model.showDetail.toggle()
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.body.weight(.bold))
                    .foregroundColor(.secondary)
                    .padding(15)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10,style: .continuous))
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(20)
                .padding(.top,40)
            */
            // MARK: button Transcaton
            VStack {
                Spacer()
                Button(action: {
                    withAnimation(.spring(response: 0.5,dampingFraction:0.9 ,blendDuration: 0.5)) {
                        showTransactionPopup.toggle()
                    }
                }) {
                    Text("Add A Transaction")
                        .frame(width: 150, height: 20)
                        .foregroundColor(.white)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .background(
                            P266_ViscosityCanvas()
                                .frame(width: 150, height: 50)
                               
                                .cornerRadius(10)
                                )
                }
                .padding(.bottom,33)
            }
            .sheet(isPresented: $showTransactionPopup) {
                transactionPopup
            }
        }
    }
    // MARK: TimeFrameButten
    private var TimeFrameButton: some View {
        let buttonWidth: CGFloat = 70
        let buttonHeight: CGFloat = 50

        return ZStack {
            HStack {
                ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                    Button(action: {
                        withAnimation(.spring(response: 0.5,dampingFraction:0.9 ,blendDuration: 0.5)) {
                            selectedTimeFrame = timeFrame
                        }
                    }) {
                        VStack(spacing: 0) {
                            Text(timeFrame.rawValue.capitalized)
                                .frame(width: buttonWidth, height: 29)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .foregroundColor(selectedTimeFrame == timeFrame ? .primary : .secondary)
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 10)
            .frame(width: 375, height: buttonHeight, alignment: .top)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .background(
                ForEach(TimeFrame.allCases.indices, id: \.self) { index in
                    if selectedTimeFrame == TimeFrame.allCases[index] {
                        Circle().fill(Color.purple).frame(width: 100)
                            .offset(x: CGFloat(index - TimeFrame.allCases.count / 2) * 100)
                            .padding(.leading,100)
                        Rectangle()
                            .fill(Color.purple)
                            .frame(width: 28, height: 5)
                            .cornerRadius(3)
                            .frame(width: buttonWidth)
                            .frame(maxHeight: .infinity, alignment: .top)
                            .offset(x: CGFloat(index - TimeFrame.allCases.count / 2) * buttonWidth)
                    }
                }
            )
        
        }
    }


// MARK: Charte
    private var Charte: some View{
        ZStack {
            Chart {
                ForEach(dailyTransactions, id: \.self) { transaction in
                    BarMark(
                        x: .value("food", transaction.date, unit: .hour),
                        y: .value("amount", transaction.amount)
                    )
                }
                
            }
        }
    }
  
    func createDate(year: Int, month: Int, day: Int, hour: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        
        let calendar = Calendar.current
        return calendar.date(from: components) ?? Date()
    }
    
    func updateTransactions() {
        if let selectedCategory = selectedCategory {
            if let transactionsSet = selectedCategory.transactions {
                if transactionsSet.allObjects is [FinancialTransactionEntity] {
                    dailyTransactions = filteredTransactions(for: selectedCategory, in: .day).map { FilteredTransaction(date: $0.date ?? Date(), amount: Int($0.amount)) }
                    weeklyTransactions = filteredTransactions(for: selectedCategory, in: .week).map { FilteredTransaction(date: $0.date ?? Date(), amount: Int($0.amount)) }
                    monthlyTransactions = filteredTransactions(for: selectedCategory, in: .month).map { FilteredTransaction(date: $0.date ?? Date(), amount: Int($0.amount)) }
                    yearlyTransactions = filteredTransactions(for: selectedCategory, in: .year).map { FilteredTransaction(date: $0.date ?? Date(), amount: Int($0.amount)) }
                }
            }
        }
    }


    
    // MARK: filter Chart Transactions
    func isTransactionInTimeFrame(_ transaction: FinancialTransactionEntity, timeFrame: TimeFrame, now: Date, calendar: Calendar) -> Bool {
        guard let transactionDate = transaction.date else { return false }
        let components: DateComponents
        switch timeFrame {
        case .day:
            components = calendar.dateComponents([.day], from: transactionDate, to: now)
            return components.day! < 1
        case .week:
            components = calendar.dateComponents([.weekOfYear], from: transactionDate, to: now)
            return components.weekOfYear! < 1
        case .month:
            components = calendar.dateComponents([.month], from: transactionDate, to: now)
            return components.month! < 1
        case .year:
            components = calendar.dateComponents([.year], from: transactionDate, to: now)
            return components.year! < 1
        }
    }

    func filteredTransactions(for category: CategoryEntity, in timeFrame: TimeFrame) -> [FinancialTransactionEntity] {
        let now = Date()
        let calendar = Calendar.current
        let transactions = category.transactions?.allObjects as? [FinancialTransactionEntity] ?? []
        let filteredTransactions = transactions.filter { transaction in
            isTransactionInTimeFrame(transaction, timeFrame: timeFrame, now: now, calendar: calendar)
        }
        return filteredTransactions
    }

    // MARK: tittel
    var cover: some View {
        GeometryReader { proxy in
            let scrollY = proxy.frame(in: .global).minY
            
            
            VStack {
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: scrollY > 0 ? 300 + scrollY : 300)
            .foregroundColor(.white)
            .background(
                ZStack {
         

                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.clear)
                        .overlay(
                            titleOverlay(scrollY: scrollY)
                        )
                }
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .frame(width: 350, height: 73)
                        .offset(y: scrollY > 0 ? -scrollY : 0)
                        .scaleEffect(scrollY > 0 ? scrollY / 1000 + 1 : 1)
                        .blur(radius: scrollY / 10)
                )
            )
        }
        .frame(height: 300)
    }

    func titleOverlay(scrollY: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color.clear)
            .frame(width: 420, height: 63)
            .overlay(
                HStack {
                  
                    
                    Text(predefinedCategories[Int(category.categoryIndex)])
                        .font(.title)
                        .fontWeight(.light)
                        .foregroundColor(Color("Background"))
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                        .matchedGeometryEffect(id: "CategoryName\(category.id?.uuidString ?? "default")", in: namespace)
                        .padding(.horizontal,-7.5)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .foregroundColor(Color("Text2"))
                                .cornerRadius(10)
                                .matchedGeometryEffect(id: "light\(category.id?.uuidString ?? "default")", in: namespace)
                                .frame(width: 50, height: 55)
                                .padding(.trailing,15)
                        )
                        .padding(.horizontal, 9)
                        .offset(y: scrollY > 0 ? -scrollY : 0)
                        .scaleEffect(scrollY > 0 ? scrollY / 1000 + 1 : 1)
                        .blur(radius: scrollY / 10)
                  
                    Spacer()
                    
                    Text("\(categories.totalTransactionsForSelectedCategory(for: category)) AED")
                        .foregroundColor(Color("Text2"))
                        .padding()
                        .padding(.horizontal, 9)
                        .padding(.trailing,25)
                        .offset(y: scrollY > 0 ? -scrollY : 0)
                        .scaleEffect(scrollY > 0 ? scrollY / 1000 + 1 : 1)
                        .blur(radius: scrollY / 10)
                }.padding(.leading,45)
                
            )
    }
// MARK: content
    var content: some View {
        VStack(alignment: .leading , spacing: 30){
            transactionList
        }.onAppear {
            selectedCategory = category
        }
    }
    
    // MARK:  transactionList
    var transactionList: some View {
        VStack(alignment: .leading, spacing: 30) {
            let transactions = filteredTransactions(for: category, in: selectedTimeFrame)
            List {
                if transactions.isEmpty {
                    Text("No transactions found. Please add something here.")
                        .foregroundColor(.secondary)
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(transactions, id: \.id) { transaction in
                        transactionRow(transaction: transaction)
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .padding()
            .background(
                Rectangle()
                    .fill(Color.clear)
                    .mask(RoundedRectangle(cornerRadius: 30, style: .continuous)))
            .frame(width: 380, height: 1000)
        }
    }


    func transactionRow(transaction: FinancialTransactionEntity) -> some View {
        if let title = transaction.title, let date = transaction.date {
            return AnyView(VStack(alignment: .leading) {
                HStack{
                    VStack(alignment: .leading){
                        Text("\(transaction.amount)")
                            .font(.title2)

                        Text(title)
                            .foregroundColor(Color.secondary)
                            .font(.body)
                            .lineLimit(1)

                    }.padding(.leading,40)
                    Spacer()
                    Text("12:00")

                    Text(self.formatDate(date: date))
                        .foregroundColor(Color.secondary)
                }.padding(.trailing,40)
                    .background(
                        RoundedRectangle(cornerRadius: 10,style: .continuous)
                            .fill(.ultraThinMaterial)
                            .frame(width: 340,height: 60)
                    )
                }
            )
        }
        return AnyView(EmptyView())
    }



    func close() {
       
        withAnimation(.spring(response: 0.5,dampingFraction:0.9 ,blendDuration: 0.5)) {
                show.toggle()
              
            
        }
        withAnimation(.spring(response: 0.5,dampingFraction:0.9 ,blendDuration: 0.5)) {
            viewState = .zero
        }
       
    }
    func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
    }
    
    var EditCategory: some View {
        ZStack{
            Button(action: {
                progressBarState = category.progressbar
                showingEditSheet = true
            }) {
                
                Text("Eddit your Diesaplen")
                    .foregroundColor(.secondary)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .frame(width: 200, height: 35)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(.purple)
                                    .frame(width: 25, height: 20)
                                    .padding(.trailing,150)
                            )
                    )
                   
            }
            .sheet(isPresented: $showingEditSheet) {
                VStack {
                    Text("Edit Category")
                        .font(.largeTitle)
                        .padding()
                    
                    Toggle(isOn: $progressBarState) {
                        Text("Show Progress Bar")
                    }
                    .padding()
                    
                    Button(action: {
                        category.progressbar = progressBarState
                        do {
                            try categories.context.save()
                        } catch {
                            print("Failed to save context after updating category: \(error)")
                        }
                        showingEditSheet = false
                    }) {
                        Text("Save Changes")
                    }
                    .padding()
                }
            }
        }
    }
    // MARK: func createNewTransaction
    func createNewTransaction() {
        if let transactionAmount = Int64(transactionAmountText), !transactionName.isEmpty {
            // Create a new transaction
            let newTransaction = FinancialTransactionEntity(context: self.categories.context)
            newTransaction.title = transactionName
            newTransaction.amount = transactionAmount
            newTransaction.date = Date()
            
            if let selectedCategory = self.selectedCategory {
                selectedCategory.addToTransactions(newTransaction)
                if self.categories.context.hasChanges {
                    do {
                        try self.categories.context.save()
                        // Fetch transactions for the selected date after saving the context
                        transactions.fetchTransactionsforSelectedDate(for: Date())
                    } catch {
                        let nserror = error as NSError
                        print("Unresolved error \(nserror), \(nserror.userInfo)")
                        // handle the error here
                    }
                }
            }
            
            transactionName = ""
            transactionAmountText = ""
        }
        
        withAnimation(.spring(response: 0.5,dampingFraction:0.9 ,blendDuration: 0.5)) {
            showTransactionPopup = false
        }
    }


}
// MARK: CourseView_Previews
struct CourseView_Previews: PreviewProvider {
    @Namespace static var namespace
    static var previews: some View {
        let context = CoreDataStack.shared.viewContext
        let sampleCategory = CategoryEntity(context: context)
        sampleCategory.categoryIndex = 3
        sampleCategory.progressbar = true
        sampleCategory.limit = 30

        let selectedCategory = CategoryEntity(context: context)
        selectedCategory.categoryIndex = 3
        selectedCategory.progressbar = false
        selectedCategory.limit = 30
      
        let transactionsEnvironment = TransactionsEnvironment(context: context)
        let categoriesEnvironment = CategoryEnvironment(context: context)

        return CiercleView(namespace: namespace, show: .constant(true), category: sampleCategory, selectedCategory: selectedCategory)
            .environmentObject(transactionsEnvironment)
            .environmentObject(categoriesEnvironment)
    }
}


struct AnimationModifier : ViewModifier{
    let positionOffset : Double
    let height = UIScreen.main.bounds.height

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            let position = geometry.frame(in: CoordinateSpace.global).midY
            ZStack {
                Color.clear
                if height >= (position + positionOffset)  {
                    content
                }
            }
        }
    }
}




extension Animation {
    static let openCard = Animation.spring(response:1, dampingFraction: 1)
    static let closeCard = Animation.spring(response: 1, dampingFraction: 1)
}



