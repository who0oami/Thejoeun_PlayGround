//
//  AddView.swift
//  Table
//
//  Created by electrozone on 3/30/26.
//

import SwiftUI

struct AddView: View {
    @Binding var todoLists:[TodoList]
    @State var newItem: String = ""
    @FocusState var isTextFieldFocused:Bool
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack(content: {
            HStack(content: {
                Text("항목 :")
                
                TextField("",text: $newItem)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 200)
                    .multilineTextAlignment(.leading)
                    .keyboardType(.default)
                    .focused($isTextFieldFocused)
            })
            .padding()
            
            Button("Add",action: {
                todoLists.append(TodoList(items: newItem, itemsImageFile: "pencil"))
                newItem = ""
                isTextFieldFocused = false
                dismiss()
            })
        })
        .navigationTitle("Add View")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    AddView(todoLists: .constant([]))
}
