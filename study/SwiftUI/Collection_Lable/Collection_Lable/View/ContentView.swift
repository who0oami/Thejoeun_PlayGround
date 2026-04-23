//
//  ContentView.swift
//  Collection_Lable
//
//  Created by electrozone on 3/31/26.
//

import SwiftUI

struct ContentView: View {
    
    @State var dataArray: [String] = ["유비", "관우", "장비", "조조", "여포", "동탁", "초선", "손견"]
    
    
    var body: some View {
        NavigationView(content: {
            ScrollView(content: {
                LazyVGrid(columns: Array(repeating: GridItem(), count: 3),spacing: 10 ,content: { //spacing 간격
                    ForEach(dataArray, id: \.self, content: {item in
                        NavigationLink(destination: DetailView(heroName: item), label: {
                            Text(item)
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 100)
                                .background(.blue)
                                .foregroundStyle(.white)
                                .clipShape(.buttonBorder)
                        })
                            
                        })
                    })
                .padding()
                })
            .navigationTitle("삼국지 인물")
            .navigationBarTitleDisplayMode( .inline )
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing ,content: {
                    NavigationLink(destination: AddView(dataArray: $dataArray), label: {
                        Image(systemName: "plus")
                    })
                })
            })
        })
    }
}

#Preview {
    ContentView()
}
