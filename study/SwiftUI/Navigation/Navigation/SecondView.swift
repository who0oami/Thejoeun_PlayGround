//
//  SecondView.swift
//  Navigation
//
//  Created by electrozone on 3/30/26.
//

import SwiftUI

struct SecondView: View {
    
    @Binding var sharedData: String
    @Binding var sharedLampStatus: String
    @FocusState var isTextFieldFocused: Bool
    @State var toggleLabel = "On"
    @State var toggleStatus = true
    
    var body: some View {
        VStack(content: {
            HStack(content: {
                Text("Message")
                
                TextField("", text: $sharedData)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 200)
                    .multilineTextAlignment(.leading)
                    .keyboardType(.default)
                    .focused($isTextFieldFocused)
            })
            
            HStack(content: {
                Spacer()
                Text(toggleLabel)
                Toggle("", isOn: $toggleStatus)
                    .labelsHidden()
                    .padding(.trailing, 20)
                    .onChange(of: toggleStatus,{
                        if toggleStatus{
                            toggleLabel = "On"
                            sharedLampStatus = "lamp_on"
                        }else{
                            toggleLabel = "Off"
                            sharedLampStatus = "lamp_off"
                        }
                    })
            })
            
        })
        .navigationTitle("Second View")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: { // 화면 넘어왔을때 제일먼저 onAppear가 실행된다
            toggleLabel = sharedLampStatus == "lamp_on" ? "On" : "Off"
            toggleStatus = sharedLampStatus == "lamp_on" ? true : false
        })
    }
}

#Preview {
    SecondView(sharedData: .constant(""), sharedLampStatus: .constant("lamp_on"))
}
