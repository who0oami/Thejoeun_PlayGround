//
//  ContentView.swift
//  TabBarPage
//
//  Created by electrozone on 3/30/26.
//

import SwiftUI

struct ContentView: View {
    @State var selection = 0
    
    var body: some View {
        VStack {
            TabView(selection: $selection, content: {
                House()
                    .tabItem ({
                        Image(systemName: "house")
                        Text("Image")
                    })
                    .tag(1)
                    .padding(.trailing, 50)
                
                Car()
                    .tabItem ({
                        Image(systemName: "car")
                        Text("Image")
                    })
                    .tag(2)
                Person()
                    .tabItem ({
                        Image(systemName: "person")
                        Text("Date")
                    })
                    .tag(3)
                
            })
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
