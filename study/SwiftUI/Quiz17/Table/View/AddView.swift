//
//  AddView.swift
//  Table
//
//  Created by electrozone on 3/30/26.
//

import SwiftUI

struct AddView: View {
    private let imageNames = ["cart", "clock", "pencil"]

    @Binding var todoLists:[TodoList]
    @State var newItem: String = ""
    @State private var selectedImageName: String = "cart"
    @FocusState var isTextFieldFocused:Bool
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(content: {
            HStack(alignment: .center, spacing: 16, content: {
                Image(selectedImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                Picker("이미지 피커", selection: $selectedImageName) {
                    ForEach(imageNames, id: \.self) { imageName in
                        HStack(spacing: 12) {
                            Image(imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                            // Text(imageName)
                        }
                        .tag(imageName)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 180, height: 120)
                .clipped()
            })
            .padding(.horizontal)

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
                todoLists.append(TodoList(items: newItem, itemsImageFile: selectedImageName))
                newItem = ""
                selectedImageName = imageNames[0]
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
