//
//  ContentView.swift
//  Picker View
//
//  Created by electrozone on 3/30/26.
//

import SwiftUI

struct ContentView: View {
    let imageFileName = ["w1", "w2", "w3", "w4", "w5", "w6", "w7", "w8", "w9", "w10"]
    @State var selectedImage = 0
    
    var body: some View {
        VStack {
            Text("Picker로 이미지 선택")
                .bold()
            
            
            Picker("", selection: $selectedImage, content: {
                ForEach(0..<imageFileName.count, id: \.self, content: {index in
                    // Picker에 Image
                    Image(imageFileName[index])
                        .resizable()
                        .frame(width: 50, height: 20)
                        .scaledToFit()
                    // Picker에 String
//                    Text("\(imageFileName[index]).jpg")
                })
            })
            .pickerStyle(.wheel)
            .padding()
            
            Text("Selected Item: \(imageFileName[selectedImage]).jpg")
            
            Image(imageFileName[selectedImage])
                .resizable()//크기 줄이는 거
                .frame(width: 350, height: 200) // 크기 맞추는 거 ( 버튼이던 뭐던 무조건 이거)
                .scaledToFit() // 내가 정한 사이즈에 모든 사이즈를 맞추는 거
                .clipShape(.rect(cornerRadius: 15))
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
