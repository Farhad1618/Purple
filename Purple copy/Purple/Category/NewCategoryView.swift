//
//  NewCategoryView.swift
//  Purple
//
//  Created by Farhad on 30/12/2022.
//

import SwiftUI
import CoreHaptics
import CoreData



struct NewCategoryView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var categories: CategoryEnvironment
    @EnvironmentObject var transactionsEnvironment: TransactionsEnvironment
    @State private var selectedCategoryIndex = 0
    @State private var amount = ""
    @State private var transactionTitle: String = ""
    @State private var showProgressBar = false
    @State private var limite: Int = 0
    @State private var expandedSection: Int? = nil
    @State private var offsetValue: ScrollOffsetValue = ScrollOffsetValue()
    @State private var currentStep: Int = 0 // Track the current step
    @Namespace var namespace: Namespace.ID
    @State private var scrollPosition: Int? = nil
    @State private var selectedTimeFrame2: TimeFrame2 = .none
    let rowSize: CGSize = CGSize(width: 100, height: 80)
    @State private var selectedLimitTimeFrame: LimitTimeFrame = .Never
    @State private var amount2: String = ""
      @State private var recurrence: TimeFrame2 = .none
    
    private var selectedTimeFrame2Description: Text {
        switch selectedTimeFrame2 {
        case .none:
            return Text("This transaction will not repeat.")
        case .day:
            return Text("This transaction will repeat every day.")
        case .week:
            return Text("This transaction will repeat every week.")
        case .month:
            return Text("This transaction will repeat every month.")
        case .year:
            return Text("This transaction will repeat every year.")
        }
    }

    func mapTimeFrame2ToLimitTimeFrame(_ timeFrame2: TimeFrame2) -> LimitTimeFrame {
        switch timeFrame2 {
        case .none:
            return .Never
        case .day:
            return .daily
        case .week:
            return .weekly
        case .month:
            return .monthly
        case .year:
            return .yearly
        }
    }

    var body: some View {
       
        VStack {
            VStack{
                Text("Create a New Category")
                    .foregroundColor(Color("Text2"))
                    .font(.title2)
                    .fontWeight(.light)
                
                        ProgressView(value: Double(currentStep), total: 3)
                            .progressViewStyle(LinearProgressViewStyle())
                            .frame(width: 335, height: 20)
                            
                            .tint(Color.purple)
                           
                         
                        
                    
            }.offset(y:30)
            
             Spacer()
             switch currentStep {
             case 0:
                
                
                 selectCategoryView
             case 1:
                 firstTransactionView
                
             case 2:
                 progressBarView
             default:
                 EmptyView()
             }
            Spacer()
           
         }
        .animation(.spring(response: 0.5,dampingFraction: 1,blendDuration: 0.5), value: currentStep)
         .navigationTitle("New Category")
         .onDisappear {
                scrollPosition = nil
            }
        .background( Color("Background"))
       
     }
    
    func generateHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
    }
    


    
    // MARK: selectCategoryView
    
    var selectCategoryView: some View {

         GeometryReader { proxyP in
            ScrollView {
                ScrollViewReader { reader in
                    ZStack {
                       
                      
                        LazyVStack {
                            // this Rectangle holds it down so starts form the senter of the screen
                            Rectangle()
                                .fill(Color.clear)
                                .frame(height: proxyP.size.height * 0.4)
                             
                            
                            
                            ForEach(0..<predefinedCategories.count, id:\.self) { index in
                                GeometryReader { proxyC in
                                    let rect = proxyC.frame(in: .named("scroll"))
                                    let y = rect.minY
                                    let opacity = self.getAlphaValue(y, proxyP.size.height)
                                    
                                    
                            
                                    Button(action: {
                                        self.selectedCategoryIndex = index
                                        self.scrollPosition = index  // Save the current scroll position
                                        self.expandedSection = index
                                        self.currentStep += 1 // Go to the next step
                                        
                                    }) {
                                        HStack {
                                            
                                            ZStack {
                                              
                                              // desplays the list of all the categories
                                                
                                                Text("\(predefinedCategories[index])")
                                                    .font(.title)
                                                    .fontWeight(.light)
                                                    .foregroundColor(Color.white)
                                                    .padding(8)
                                                    .matchedGeometryEffect(id: "CateogryNameInNewCateogry\(index)", in: namespace)
                                                    .opacity(opacity)
                                                    .padding(.leading,20)
                                         
                                                    
                                            }
                                            Spacer()
                                        }
                                     
                                    }.background(
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(Color.clear)
                                            .frame(width: UIScreen.main.bounds.width * 0.72, height: 73)
                                            .opacity(opacity)
                                        
                                    )
                                    .frame(width: 300, height: 77)
                                    
                                }.buttonStyle(PlainButtonStyle())
                                
                            }
                            .frame(width: self.rowSize.width, height: self.rowSize.height)
                            Rectangle()
                                .fill(Color.clear)
                                .frame(height: max(proxyP.size.height * 0.5, 1))
                            
                        }
                        .offset(x: -proxyP.size.width * 0.3)
                  
                        OffsetInScrollView(named: "scroll")
                    }.onChange(of: currentStep) { newValue in  // Use onChange to detect when currentStep changes
                        if newValue == 0, let position = scrollPosition {  // When going back to selectCategoryView, scroll to the remembered position
                            reader.scrollTo(position, anchor: .top)
                        }
                    }
                    
                }
            }.onChange(of: selectedCategoryIndex) { _ in
                generateHapticFeedback()
            }
            .modifier(OffsetOutScrollModifier(offsetValue: self.$offsetValue, named: "scroll"))
            .padding()
        }
    }
    var transactionAmount: Double {
          let formatter = NumberFormatter()
          formatter.numberStyle = .decimal
          return formatter.number(from: amount)?.doubleValue ?? 0.0
      }
  
    // MARK: firstTransactionView
    var firstTransactionView: some View {
      
        ScrollView {
            VStack (alignment: .leading){
                 
                 ZStack(alignment: .leading){
                    
                     
                     HStack{
                         RoundedRectangle(cornerRadius: 3, style: .continuous)
                             .foregroundColor(Color("Text2"))
                             .matchedGeometryEffect(id: "lightInNewCateogry\(selectedCategoryIndex)", in: namespace)
                             .frame(width: 20, height: 55)
                             .offset(x:-20)
                             .padding()
                         
                      

                     }
                     HStack{
                         
                         Text("\(predefinedCategories[selectedCategoryIndex])")
                             .font(.title)
                             .fontWeight(.light)
                             .foregroundColor(Color.white)
                             .padding(8)
                             .background(.ultraThinMaterial)
                             .matchedGeometryEffect(id: "CateogryNameInNewCateogry\(selectedCategoryIndex)", in: namespace)
                         Spacer()
                         Text("\(amount) AED")
                             .font(.callout)
                             .foregroundColor(Color("Text2"))
                             .padding(.trailing,25)
                     }
                 }  .padding(.leading, 25)
                 .background(
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(.opacity(0.1))
                        .frame(width: UIScreen.main.bounds.width * 0.94, height: 73)
                       
                    
                )
               
                 
                 Text("First Transaction (optional)")
                     .padding(.leading)
                     .foregroundColor(.secondary)
                     .padding()
                 VStack{
                     HStack {
                         // MARK: Enter Transation
                         ZStack(alignment: .leading) {
                             HStack{
                                 Text("Titel ")
                                     .foregroundColor(.secondary)
                                     .padding(.bottom, 100)
                                     .padding(.leading, 7)
                                 
                                 Text("amoint ")
                                     .foregroundColor(.secondary)
                                     .padding(.bottom, 100)
                                     .padding(.leading, 120)
                             }
                             RoundedRectangle(cornerRadius: 10, style: .continuous)
                                 .foregroundColor(Color.purple)
                                 .cornerRadius(10)
                                 .padding(8)
                                 .frame(width: 39, height: 60)
                                 .offset(x: -8)
                                 .padding(.leading, 7)
                                 .opacity(0.82)
                             
                             HStack{
                                 TextField("nom nom", text: $transactionTitle)
                                     .font(.title)
                                     .fontWeight(.light)
                                     .foregroundColor(.white)
                                     .padding(6)
                                     .background(.ultraThinMaterial)
                                     .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                     .frame(width: 150)
                                     .padding(.leading, 7)

                                 
                                 
                                 // Enter first transaction
                                 TextField("1618", text: $amount)
                                     .keyboardType(.decimalPad)
                                     .font(.title)
                                     .fontWeight(.light)
                                     .foregroundColor(.white)
                                     .padding(6)
                                     .background(.ultraThinMaterial)
                                     .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                     .frame(width: 150)
                                     .padding(.leading, 7)
                              
                                 
                             }
                             Spacer()
                         }
                         Spacer()
                     }
                     VStack(alignment: .leading){
                        
                         selectedTimeFrame2Description
                             .foregroundColor(.secondary)
                         TimeFrame2Button
                     }

                 } .background(
                    RoundedRectangle(cornerRadius: 10 ,style: .continuous)
                        .fill(.opacity(0.05))
                        .frame(width: 370,height: 240)
                )
                 .padding()
                
                 HStack{
                
                     Button {
                         self.currentStep -= 1 // Go back to the previous step
                     } label: {
                         ZStack(alignment: .leading){
                             HStack{
                            
                             }
                             Text("Back")
                                 .keyboardType(.decimalPad)
                                 .font(.title2)
                                 .fontWeight(.light)
                                 .foregroundColor(Color("Text2"))
                                 .opacity(0.5)
                             
                               
                                 .background(
                                    RoundedRectangle(cornerRadius: 10,style: .continuous)
                                        .fill(.ultraThinMaterial)
                                        .frame(width: 150,height: 40)
                                       
                                 )
                                 
                    
                         }.padding(.leading, 55)
                     }

                     Spacer()
                     
                     Button("Next") {
                         self.currentStep += 1 // Go to the next step
                     }
                         .font(.title2)
                         
                         .foregroundColor(.white)
                         
                       .background(
                          RoundedRectangle(cornerRadius: 10,style: .continuous)
                              .fill(.ultraThinMaterial)
                              .frame(width: 150,height: 40)
                              .background(
                                
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .foregroundColor(Color.purple)
                                    .cornerRadius(10)
                                    .padding(8)
                                    .frame(width: 50, height: 55)
                                    .offset(x: -8)
                                    .padding(.leading, 7)
                                    .opacity(0.82)
                                
                              )
                       )
                       .padding(.leading,100)
                     Spacer()
                 }
                 
                 .padding()
                 Spacer()
            }.padding(.top,40)
        }
    }
    
// MARK: TimeFrame2Button
        private var TimeFrame2Button: some View {
            let buttonWidth: CGFloat = 50
            let buttonHeight: CGFloat = 50

            return ZStack {
                HStack {
                    ForEach(TimeFrame2.allCases, id: \.self) { timeFrame in
                        Button(action: {
                            withAnimation(.spring(response: 1, dampingFraction: 1, blendDuration: 1)) {
                                
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
                .padding(.top, 10)
                .frame(width: 345, height: buttonHeight, alignment: .top)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .background(
                    
                    ForEach(TimeFrame2.allCases.indices, id: \.self) { index in
                        if selectedTimeFrame2.rawValue == TimeFrame2.allCases[index].rawValue {
                          
                            Circle().fill(Color.purple).frame(width: 100)
                                .offset(x: CGFloat(index - TimeFrame2.allCases.count / 2) * 70)
                      
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
    
    // MARK: DisciplinePicker
    private var DisciplinePicker: some View {
        let buttonWidth: CGFloat = 80
        let buttonHeight: CGFloat = 50

        return ZStack {
            HStack(spacing: 0){
                ForEach(LimitTimeFrame.allCases, id: \.self) { limitTimeFrame in
                    Button(action: {
                        withAnimation(.spring(response: 1, dampingFraction: 1, blendDuration: 1)) {
                            selectedLimitTimeFrame = limitTimeFrame
                        }
                    }) {
                        VStack(spacing: 0) {
                            Text(String(describing: limitTimeFrame))
                                .frame(width: buttonWidth, height: 29)
                            
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .foregroundColor(selectedLimitTimeFrame == limitTimeFrame ? .primary : .secondary)
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 10)
            .frame(width: 385, height: buttonHeight, alignment: .top)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .background(
                ForEach(LimitTimeFrame.allCases.indices, id: \.self) { index in
                    if selectedLimitTimeFrame.rawValue == LimitTimeFrame.allCases[index].rawValue {
                        Circle().fill(Color.purple).frame(width: 100)
                            .offset(x: CGFloat(index - LimitTimeFrame.allCases.count / 2) * 80)
                        Rectangle()
                            .fill(Color.purple)
                            .frame(width: 28, height: 5)
                            .cornerRadius(3)
                            .frame(width: buttonWidth)
                            .frame(maxHeight: .infinity, alignment: .top)
                            .offset(x: CGFloat(index - LimitTimeFrame.allCases.count / 2) * buttonWidth)
                    }
                }
            )
        }
    }
    
    // MARK: progressBarView
    var progressBarView: some View {
        ScrollView {
            VStack {
                
                ZStack(alignment: .leading){
                    
                    HStack{
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .foregroundColor(Color("Text2"))
                            .matchedGeometryEffect(id: "lightInNewCateogry\(selectedCategoryIndex)", in: namespace)
                            .frame(width: 50, height: 55)
                            .offset(x:-20)
                            .padding()
                    }
                    HStack{
                        Text("\(predefinedCategories[selectedCategoryIndex])")
                            .font(.title)
                            .fontWeight(.light)
                            .foregroundColor(Color.black)
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .matchedGeometryEffect(id: "CateogryNameInNewCateogry\(selectedCategoryIndex)", in: namespace)
                            .cornerRadius(10)
                        Spacer()
                        Text("\(amount)")
                            .font(.callout)
                            .foregroundColor(Color("Text2"))
                            .padding(.trailing,25)
                    }.background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(showProgressBar ? Color.purple : Color.clear)
                            .frame(width: UIScreen.main.bounds.width * 0.4, height: 55)
                            .padding(.trailing,140)


                             
                    )
                }  .padding(.leading, 25)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(.opacity(0.1))
                            .frame(width: UIScreen.main.bounds.width * 0.94, height: 73)
                    )
                    .padding(.top,40)
                
            Text("you can choose to put a limit here on how much you spend ")
                    .foregroundColor(.secondary)
                    .padding(.top,30)
                ProgresTogelView(isOn: $showProgressBar)
                    .padding()
                
                VStack(alignment: .leading){
                    if showProgressBar {
                        TextField("Enter a limit", value: $limite, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                            .font(.title)
                            .fontWeight(.light)
                            .foregroundColor(.white)
                            .padding(6)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .frame(width: 150)
                            .padding(.vertical,33)
                        
                        DisciplinePicker
                    } else {
                        EmptyView()
                    }
                }
                .frame(height: 200) // Set a fixed height for the VStack
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.opacity(0.05))
                        .frame(width: UIScreen.main.bounds.width * 0.96, height: 200) // Set the same fixed height for the background
                )
                .padding(30)


                
                
                // MARK: Create category
                
      
                
                // Then use it in your button action
                Button("Create New Category") {
                    print("Amount: \(amount)") // Logging the amount value
                    if let amount = Double(amount) {
                        // Create a new transaction
                        let transaction = FinancialTransactionEntity(context: self.categories.context)
                        
                        // Fetch the category name
                        let categoryName = predefinedCategories[selectedCategoryIndex]
                        
                        // Set the transaction title
                        transaction.title = transactionTitle.isEmpty ? "\(categoryName) \(categories.totalTransactionsForSelectedCategory(for: categories.categories[selectedCategoryIndex]) + 1)" : transactionTitle
                        transaction.amount = Int64(amount)
                        transaction.date = Date()
                        
                        // Add the new category with the created transaction
                        self.categories.createOrUpdateCategory(withIndex: selectedCategoryIndex, showProgressBar: $showProgressBar.wrappedValue, limit: Int64(limite), limitTimeFrame: mapTimeFrame2ToLimitTimeFrame(selectedTimeFrame2), transaction: transaction)
                        
                        do {
                            try self.categories.context.save() // Save the context
                            self.categories.fetchCategories(for: Date()) // Fetch categories after saving
                            self.transactionsEnvironment.fetchTransactionsforSelectedDate(for: Date()) // Fetch transactions after saving
                        } catch {
                            print("Failed to save context: \(error)") // Log an error if saving fails
                        }
                        
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        print("Failed to convert amount to Double.") // Log an error if the conversion fails
                    }
                }.foregroundColor(.white)
                    .font(.title3)
                    .frame(width: 300,height: 70)
                   
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                    .background(
                        newCeateButtonBacground()
                            .frame(width: 300,height: 70)
                            .cornerRadius(10)
                           
                    )
               
            }
        }
    }
    
/*
    var createCategoryView: some View {
        VStack {
            Button("Create") {
                if let amount = Double(amount) {
                    // Create a new transaction
                    let transaction = FinancialTransactionEntity(context: self.categories.context)
                    transaction.title = predefinedCategories[selectedCategoryIndex]
                    transaction.amount = Int64(amount)
                    transaction.date = Date()
                    
                    // Add the new category with the created transaction
                    self.categories.createOrUpdateCategory(withIndex: selectedCategoryIndex, transaction: transaction)
                    
                    presentationMode.wrappedValue.dismiss()
                }
            }
            Button("Skip") {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }

*/

    

    private func getAlphaValue(_ current: Double, _ total: Double) -> CGFloat {
        let x = Double(current) / Double(total)
        let y = (sin(-1.1 * (.pi * x) - .pi / 1))
        return CGFloat(y)
    }
    

}
// MARK: NewCategoryView_Previews
struct NewCategoryView_Previews: PreviewProvider {

    static var previews: some View {
        let context = CoreDataStack.shared.viewContext
        return NewCategoryView().environmentObject(CategoryEnvironment(context: context))
        
            .preferredColorScheme(.dark)
    }
}

// MARK: the Scroul effect

fileprivate
struct ScrollOffsetValue: Equatable {
    var x: CGFloat = 0
    var y: CGFloat = 0
    var contentSize: CGSize = .zero
    
}

fileprivate
struct ScrollOffsetKey: PreferenceKey {
    typealias Value = ScrollOffsetValue
    static var defaultValue = ScrollOffsetValue()
    static func reduce(value: inout Value, nextValue: () -> Value) {
        let newValue = nextValue()
        value.x += newValue.x
        value.y += newValue.y
        value.contentSize = newValue.contentSize
    }
}

fileprivate
struct OffsetInScrollView: View {
    let named: String
    var body: some View {
        GeometryReader { proxy in
            let offsetValue = ScrollOffsetValue(x: proxy.frame(in: .named(named)).minX,
                                                y: proxy.frame(in: .named(named)).minY,
                                                contentSize: proxy.size)
            Color.clear.preference(key: ScrollOffsetKey.self, value: offsetValue)
        }
    }
}

fileprivate
struct OffsetOutScrollModifier: ViewModifier {
    
    @Binding var offsetValue: ScrollOffsetValue
    let named: String
    
    func body(content: Content) -> some View {
        GeometryReader { proxy in
            content
                .frame(height: proxy.size.height * 3.0)
                .coordinateSpace(name: named)
                .onPreferenceChange(ScrollOffsetKey.self) { value in
                    offsetValue = value
                    offsetValue.contentSize = CGSize(width: offsetValue.contentSize.width - proxy.size.width, height: offsetValue.contentSize.height - proxy.size.height)
                }
        }
    }
}

fileprivate
struct DetailView: View {
    
    let index: Int
    
    var body: some View {
        Text("\(index)")
            .font(.largeTitle)
    }
}
