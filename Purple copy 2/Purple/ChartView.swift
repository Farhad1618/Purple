//
//  ChartView.swift
//  Purple
//
//  Created by Farhad on 11/03/2023.
//

import SwiftUI
import GZMatchedTransformEffect
struct ChartView: View {
    var namespace: Namespace.ID
    @Binding var show: Bool
    var body: some View {
        ZStack{
            Circle()
                .fill(Color.pink)
                .frame(width: 1000, height: 1000)
                .matchedTransformEffect(id: "1618", in: namespace)
              
        }  .onTapGesture {
            withAnimation {
                show.toggle()
            }
        }
    }
}

struct ChartView_Previews: PreviewProvider {
    @Namespace static var namespace
    static var previews: some View {
        ChartView(namespace: namespace, show: .constant(true))
    }
}
