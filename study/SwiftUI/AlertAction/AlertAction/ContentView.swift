//
//  ContentView.swift
//  AlertAction
//
//  Created by electrozone on 3/30/26.
//

import SwiftUI

struct ContentView: View {
    @State var isAlert = false
    @State var isActionSheet = false
    
    var body: some View {
        VStack {
            Text("Alert와 Action sheet")
                .bold()
                .padding()
            
            HStack(spacing: 05, content: {
                Button("Alert", action: {
                    isAlert = true
                })
                .alert("Title", isPresented: $isAlert, actions: {
                    Button("Action Default", role: .none, action: {
                        print("Action Default")
                    })
                    Button("Action Destructive", role: .destructive, action: {
                        print("Action Destructive")
                    })
                    Button("Action Cancel", role: .cancel, action: {
                        print("Action Cancel")
                    })
                })
                
                Button("Action Sheet", action: {
                    isActionSheet = true
                })
                .confirmationDialog("Title", isPresented: $isActionSheet,
                    titleVisibility: .visible,  actions: {
                    Button("Action Default", role: .none, action: {
                        print("Action Default")
                    })
                    Button("Action Destructive", role: .destructive, action: {
                        print("Action Destructive")
                    })
                    Button("Action Cancel", role: .close, action: {
                        print("Action Cancel")
                    })
                })
                
                
            })
            
            }
        .padding()
    }
}

#Preview {
    ContentView()
}
