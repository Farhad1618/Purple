//
//  ProgresTogelView.swift
//  Purple
//
//  Created by Farhad on 18/06/2023.
//

import SwiftUI
struct ProgresTogelView: View {
    @Binding var isOn: Bool
    let buttonWidth: CGFloat = 80
    let buttonHeight: CGFloat = 50
    
    var body: some View {
        VStack{
            ZStack {
                HStack {
                    ForEach(["No limit", "Discipline"], id: \.self) { state in
                        Button(action: {
                            withAnimation(.spring(response: 1, dampingFraction: 1, blendDuration: 1)) {
                                isOn = (state == "Discipline")
                            }
                        }) {
                            VStack(spacing: 0) {
                                Text(state)
                                    .frame(width: buttonWidth, height: 29)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .foregroundColor(isOn == (state == "Discipline") ? .primary : .secondary)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.top, 10)
                .frame(width: 345, height: buttonHeight, alignment: .top)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .background(
                    ForEach(["No limit", "Discipline"].indices, id: \.self) { index in
                        if isOn == (index == 1) {
                            Rectangle().fill(Color.purple).frame(width: 100,height: 50)
                                .offset(x: CGFloat(Double(index) - 0.5) * 200)
                      
                        }
                    }
                )
            }
        }
    }
}


struct ProgresTogelView_Previews: PreviewProvider {
    @State static var isOn: Bool = false

    static var previews: some View {
        ProgresTogelView(isOn: $isOn)
    }
}
