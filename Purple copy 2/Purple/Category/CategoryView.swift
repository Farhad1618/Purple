//
//  CategoryView.swift
//  Purple
//
//  Created by Farhad on 20/12/2022.
//

import SwiftUI
import CoreData

struct CategoryView: View {
    @Namespace var namespace
    @State var show = false
    @State var chicked = false
    @EnvironmentObject var categories: CategoryEnvironment
    @EnvironmentObject var transactionsEnvironment: TransactionsEnvironment
    @State var selectedCategory: CategoryEntity?
    @State var showStatusBar = true
    @EnvironmentObject var model: Model
    @State var viewState: CGSize = .zero
    @State private var scrollViewContentOffset = CGFloat(0)
    @State private var showingSheet: Bool = false
    @State var showingDatePicker = false
    @EnvironmentObject var dateCategories: DateCategoriesEnvironment
    @State var selectedDateIndex = 0
    let endingDate: Date = Date()
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    
    var body: some View {
     
        ZStack (alignment: .top){
            // MARK: Date
            ZStack(alignment: .bottom) {
                Color("Background")
                    .ignoresSafeArea()
                VStack {
                    if chicked  {
                        
                        HStack {
                            
                            
                            Text("\(transactionsEnvironment.transactions.reduce(0) { $0 + Int64($1.amount) })")
                                .matchedGeometryEffect(id: "totalamount", in: namespace)
                                .font(.system(size: 170, weight: .ultraLight))
                                .minimumScaleFactor(0.01)
                                .opacity(0.8)
                                .foregroundColor(Color("Text2"))
                                .lineLimit(1)
                                .padding([.leading, .bottom])
                            
                            
                            Text("AED")
                                .fontWeight(.light)
                                .padding(.top, 80)
                                .foregroundColor(Color("Text2"))
                                .matchedGeometryEffect(id: "aed", in: namespace)
                                .opacity(0.5)
                                .padding()
                                .padding(.top,15)
                            Spacer()
                            
                        }
                        
                        
                        .padding(.top,30)
                        .zIndex(2)
                        
                        
                        
                        
                    }
                    if !chicked {
                        ScrollView {
                            VStack(alignment: .trailing) { // changed HStack to VStack and added alignment: .trailing
                                Spacer()
                            
                                Text("\(transactionsEnvironment.transactions.reduce(0) { $0 + Int64($1.amount) })")
                                    .matchedGeometryEffect(id: "totalamount", in: namespace)
                                    .font(.system(size: 80, weight: .ultraLight))
                                   
                                    .foregroundColor(Color("Text2"))
                                    .lineLimit(1)
                                    .padding(.top,70)
                                
                                Text("Today")
                                    .font(.subheadline)
                                    .fontWeight(.thin)
                                    .foregroundColor(Color("Text2"))
                                    .padding(.bottom)
                                   
                                
                                // added total transactions for past 7 days and current month
                                Text("\(categories.totalTransactionsPast7Days)")
                                    .font(.title)
                                    .foregroundColor(Color("Text2"))
                                    .padding(.top)
                                    .lineLimit(1)
                                Text("Last 7 days ")
                                    .font(.subheadline)
                                    .fontWeight(.thin)
                                    .foregroundColor(Color("Text2"))
                                    .padding(.bottom)
                                   
                                Text("\(categories.totalTransactionsCurrentMonth)")
                                    .font(.title)
                                    .foregroundColor(Color("Text2"))
                                    .padding(.top)
                                    .lineLimit(1)
                                Text("Last 30 days ")
                                    .font(.subheadline)
                                    .fontWeight(.thin)
                                    .foregroundColor(Color("Text2"))
                                    .padding(.bottom)

                                
                            }.padding(.leading,250)
                            .padding() // to add some space around the text
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 10,style: .continuous)
                                .fill(.ultraThinMaterial)
                                .frame(width: 400, height: 1000)
                                .ignoresSafeArea() // Fill the whole screen
                        )
                        .zIndex(2)
                    }
                    
                    Spacer()
                }
                
                .background(
                    RoundedRectangle(cornerRadius: 10,style: .continuous)
                        .fill(.ultraThinMaterial)
                        .frame(width: 373,height: 180)
                        .padding(.bottom,495)
                    
                )
                 
                .onTapGesture {
                    withAnimation(.spring(response: 0.5,dampingFraction:0.9 ,blendDuration: 0.5)) {
                        chicked.toggle()
                    }
                }
                .background(
                    P266_ViscosityCanvas()
                        .frame(width: 373,height: 140)
                        .opacity(0.5)
                        .cornerRadius(10)
                        .padding(.bottom,500)
                )
                .zIndex(1)
                
                ScrollView {
                    VStack {
                        Spacer(minLength: 0)
                        
                        LazyVStack {
                            Rectangle()
                                .fill(.clear)
                                .frame(width: 100, height: 223)
                            
                            // MARK: CircleItem
                            if !show {
                                ForEach(categories.categories) { category in
                                    CircleItem(namespace: namespace, category: category, show: $show)
                                        .onTapGesture {
                                            withAnimation(.spring(response: 0.5,dampingFraction:0.9 ,blendDuration: 0.5)) {
                                                show.toggle()
                                                selectedCategory = category
                                                categories.fetchTransactions(for: category)
                                            }
                                        }
                                }
                            }
                        }
                    }
                }
                .zIndex(0)
                
                if show {
                    if let selectedCategory = selectedCategory, show {
                        CiercleView(namespace: namespace, show: $show, category: selectedCategory)
                            .zIndex(3)
                        //  .onTapGesture {
                        //      withAnimation(.spring(response: 1, dampingFraction: 1, blendDuration: 1)) {
                        //          show.toggle()
                        //      }
                        //  }
                    }
                }
                
                Button(action: {
                    showingSheet.toggle()
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 20))
                        .foregroundColor(Color.secondary)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                    
                }
                
                .sheet(isPresented: $showingSheet) {
                    ZStack {
                        Color.black.edgesIgnoringSafeArea(.all)
                        NewCategoryView()
                    }
                }
            }  .statusBar(hidden: true)
            Button(action: {
                showingDatePicker = true
            }){
              
                Text("12 3 2023")
                    .foregroundColor(.secondary)
                
              /*
                 Button("Delete All Categories") {
                 categories.deleteAllCategories()
                 }
               */
            }

               // MARK: DatePicker Sheet
            .sheet(isPresented: $showingDatePicker) {
                DatePickerView(selectedDate: $transactionsEnvironment.selectedDate, onDateSelection: {
                    let selectedDay = Calendar.current.startOfDay(for: transactionsEnvironment.selectedDate)
                    categories.fetchCategories(for: selectedDay)
                })

            }   .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .frame(width: 300, height: 30)
            )


               
            }.background(Color.clear)
            .padding(.bottom,-5)
            
        }
        
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()

        
    }
struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        let context = CoreDataStack.shared.viewContext
        let mockTransactionsEnvironment = TransactionsEnvironment(context: context)
        let mockModel = Model() // Initialize your Model object accordingly
        let mockCategoryEnvironment = CategoryEnvironment(context: context)

        CategoryView()
            .environmentObject(mockTransactionsEnvironment)
            .environmentObject(mockModel)
            .environmentObject(mockCategoryEnvironment)
    }
}
