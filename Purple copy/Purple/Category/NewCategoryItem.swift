//
//  NewCategoryItem.swift
//  Purple
//
//  Created by Farhad on 22/01/2023.
//

import SwiftUI

struct NewCategoryItem: View {
    
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.purple, .purple, .red]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 100)
            .background(
                Color(UIColor.systemBackground)
                    .edgesIgnoringSafeArea(.all)
            )
        }
    }
}
struct NewCategoryItem_Previews: PreviewProvider {
    static var previews: some View {
        NewCategoryItem()
    }
}
