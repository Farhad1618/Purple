//
//  DatePicker.swift
//  Purple
//
//  Created by Farhad on 12/06/2023.
//

import SwiftUI
struct DatePickerView: View { 
    
    @Binding var selectedDate: Date
    var endingDate: Date = Date()

    let onDateSelection: () -> Void

    var body: some View {
        VStack{
            Text("Chose which day you wanna see your expenses")
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            DatePicker("", selection: $selectedDate, in: ...endingDate, displayedComponents: [.date])
                .accentColor(Color.purple)
                .padding()
                .datePickerStyle(
                GraphicalDatePickerStyle()
                )
                .onChange(of: selectedDate) { newValue in
                    // Update the selected date
                    selectedDate = newValue
                    dateChanged()
                }

        }
    }
    private func dateChanged() {
            onDateSelection()
        }
}

struct DatePickerView_Previews: PreviewProvider {
    static var previews: some View {
        DatePickerView(selectedDate: .constant(Date()), onDateSelection: { })
            .preferredColorScheme(.dark)
    }
}
