//
//  HomeView.swift
//  Purple
//
//  Created by Farhad on 19/11/2022.
//

import SwiftUI
import CoreData
struct HomeView: View {

    @EnvironmentObject var categoryEnvironment: CategoryEnvironment
    @EnvironmentObject var categories: CategoryEnvironment
    
    var body: some View {
        
    VStack {
        
        CategoryView()
            .environmentObject(categoryEnvironment)
                 // Add the ChartItem here
         }
     }
 }

struct HomeView_Previews: PreviewProvider {
    static var context = PersistenceController.shared.container.viewContext

    static var previews: some View {
        HomeView()
            .environmentObject(CategoryEnvironment(context: context))
            .preferredColorScheme(.dark)
    }
}
