//
//  ProgressBare.swift
//  Purple
//
//  Created by Farhad on 07/04/2023.
//

import SwiftUI
struct ProgressBare: View {
    var total: Double
    var current: Double
    @State private var blurAmount: CGFloat = 0.0

    var body: some View {
        ZStack {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                 
                    Rectangle()
                        .frame(width: min(CGFloat(current/total)*geo.size.width, geo.size.width), height: geo.size.height)
                        .foregroundColor(getProgressColor())
                        .cornerRadius(10)
                   
                }
            }.frame(width: 310, height: 55)
         
                .padding(.trailing,-50)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 3.0).repeatForever()) {
                    self.blurAmount = 50.0
                }
            }
        }
    }
    
    func getProgressColor() -> Color {
        if current >= total {
            return Color(.red)
             
        } else if current > 0 {
            return   Color.purple
                
        }  else {
            return .red
        }
    }
}


struct ProgressBare_Previews: PreviewProvider {
    static var previews: some View {
        let context = CoreDataStack.shared.viewContext
      return  ProgressBare(total: 100, current: 90).environmentObject(CategoryEnvironment(context: context))
    }
}
