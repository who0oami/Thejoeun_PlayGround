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
                FirstPage()
                    .tabItem ({
                        Image(systemName: "sun.max")
                        Text("Sun")
                    })
                    .tag(1)
                    .padding(.trailing, 50)
                
                SecondPage()
                    .tabItem ({
                        Image(systemName: "sun.snow")
                        Text("Sun&Snow")
                    })
                    .tag(2)
                
            })
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
