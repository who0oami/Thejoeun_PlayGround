//
//  detailView.swift
//  Table
//
//  Created by electrozone on 3/30/26.
//

import SwiftUI

struct DetailView: View {
    var todoList : TodoList
    
    var body: some View {
      VStack(content: {
          Image(todoList.itemsImageFile)
              .resizable()
              .frame(width: 100,height: 100)
              .fixedSize()
              .padding(.bottom,10)
              .scaledToFit()
          
          Text(todoList.items)
      })
      .navigationTitle("Detail View")
      .navigationBarTitleDisplayMode(.inline)
      
    }
}

#Preview {
    DetailView(todoList: TodoList(items: "aaa", itemsImageFile: "cart"))
}
