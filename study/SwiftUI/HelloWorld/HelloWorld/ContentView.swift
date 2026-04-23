//
//  ContentView.swift
//  HelloWorld
//
//  Created by electrozone on 3/26/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Hello World")
            .font(.system(size: 20))
            .bold()
            .foregroundStyle(.blue)
            .padding()
            .background(.yellow)
    }
}

#Preview {
    ContentView()
}
