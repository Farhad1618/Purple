//
//  Chart.swift
//  Purple
//
//  Created by Farhad on 11/03/2023.
//

import SwiftUI

struct Chart: View {
    @Namespace var namespace
    @State var show = false
      
      var body: some View {
          ZStack {
              if !show {
                  ChartItem(namespace: namespace, show: $show)
              }
              if show {
                  ChartView(namespace: namespace, show: $show)
              }
          }
      }
  }

struct Chart_Previews: PreviewProvider {
    static var previews: some View {
        Chart()
    }
}
