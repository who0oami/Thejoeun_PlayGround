//
//  ContentView.swift
//  Navigation
//
//  Created by electrozone on 3/30/26.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var lampData: LampData
    @FocusState var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack (content: {
                Image(lampData.sharedLampStatus)
                    .resizable()
                    .frame(width: 180, height: 300)
                    .fixedSize()
                    .padding(.bottom, 10)
                    .scaledToFit()
                HStack(content: {
                    Text("Message")
                    
                    TextField("",text: $lampData.sharedData)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 200)
                        .multilineTextAlignment(.leading)
                        .keyboardType(.default)
                        .focused($isTextFieldFocused)
                    
                    NavigationLink(destination:  SecondView(), label: {
                        Text("수정 ")
                    })
                })
                .padding()
            })
            .navigationTitle("Main Title")
            .navigationBarTitleDisplayMode(.large)
            
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(LampData())
}
