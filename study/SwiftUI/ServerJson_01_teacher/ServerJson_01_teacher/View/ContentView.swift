//
//  ContentView.swift
//  ServerJson_01_teacher
//
//  Created by electrozone on 3/31/26.
//

import SwiftUI

struct ContentView: View {
    
    @State var students: [StudentJSON] = []
    
    var body: some View {
        NavigationView(content: {
            List(students, id: \.code, rowContent: {student in
                VStack(alignment: .leading, content: {
                    Text("성명 : \(student.name)")
                    Text("학번 : \(student.code)")
                        .font(.system(size:14))
                })
            })
            .navigationTitle("Students")
        })
        .padding()
        .onAppear(perform: {
            let queryModel = QueryModel()
            Task{
                students = try await queryModel.loadData(url: URL(string: "https://zeushahn.github.io/Test/ios/student.json")!)
            }
        })
    }
}

#Preview {
    ContentView()
}
