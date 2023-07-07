//
//  CategoryForm.swift
//  Purple
//
//  Created by Farhad on 20/12/2022.
//

import SwiftUI

struct CategoryForm: View {
    @State var category: Category

    var body: some View {
        Form {
            TextField("Category name", text: $category.name)
            Button(action: {
                // Save the category and dismiss the form
            }) {
                Text("Save")
            }
        }
        .navigationBarTitle(category.name.isEmpty ? "New Category" : "Edit Category")
    }
}
struct CategoryForm_Previews: PreviewProvider {
    static var previews: some View {
        CategoryForm(category: categories)
    }
}

