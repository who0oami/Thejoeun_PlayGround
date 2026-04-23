//
//  ContentView.swift
//  Navigation
//
//  Created by electrozone on 3/30/26.
//

import SwiftUI

struct ContentView: View {
    
    @State var sharedData: String = ""
    @State var sharedLampStatus = "lamp_on"
    @FocusState var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationStack{
            VStack(content: {
                Image(sharedLampStatus)
                    .resizable()
                    .frame(width: 180, height: 300)
                    .fixedSize() // 흔들리지 않게 사이즈 고정
                    .padding(.bottom, 10)
                    .scaledToFit()
                
                HStack(content: {
                    Text("Message")
                    
                    TextField("", text: $sharedData)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 200)
                        .multilineTextAlignment(.leading) // 정렬, 글자니까-> .leading
                        .keyboardType(.default)
                        .focused($isTextFieldFocused)
                    
                    NavigationLink(destination: SecondView(sharedData: $sharedData, sharedLampStatus: $sharedLampStatus ), label: {
                        Text("수정")
                        
                    })
                })
                .padding()
            })
            .navigationTitle("Main Title") // 위치 잘 확인
            .navigationBarTitleDisplayMode(.inline)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
