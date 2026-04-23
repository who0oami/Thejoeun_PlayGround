//
//  ContentView.swift
//  Computer
//
//  Created by electrozone on 3/26/26.
//

import SwiftUI

struct ContentView: View {
    @State var productName = ""
    @State var screenSize = ""
    @State var weight = ""
    @State var bag = ""
    @State var color = ""
    
    var body: some View {
        VStack(spacing: 20, content: {
            
            Text("Computer 사양")
                .bold()
                .padding(50)
            
            HStack(spacing:10, content: {
                Text("제품명 :")
                    .frame(minWidth: 80, alignment: .leading)
                TextField("제품명을 입력하세요", text: $productName)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 200)
            })
            
            HStack(spacing:10, content: {
                Text("화면크기 :")
                    .frame(minWidth: 80, alignment: .leading)
                TextField("화면크기를 입력하세요", text: $screenSize)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 200)
            })
            HStack(spacing:10, content: {
                Text("무게 :")
                    .frame(minWidth: 80, alignment: .leading)
                TextField("무게를 입력하세요", text: $weight)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 200)
            })
            HStack(spacing:10, content: {
                Text("가방 :")
                    .frame(minWidth: 80, alignment: .leading)
                TextField("가방유무를 입력하세요", text: $bag)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 200)
            })
            HStack(spacing:10, content: {
                Text("색상 :")
                    .frame(minWidth: 80, alignment: .leading)
                TextField("색상을 입력하세요", text: $color)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 200)
            })
            
            Button("OK", action: {
                let productName_T: String = "맥북프로"
                let screensize_T: Int = 14
                let weight_t: Double = 1.63
                let bag_t: Bool = false
                let color_t: Character = "백"
                
                productName = productName_T
                screenSize = String(screensize_T)
                weight = String(weight_t)
                bag = String(bag_t)
                color = String(color_t)
            })
            .padding()
            .frame(width: 80)
            .background(.blue)
            .foregroundStyle(.white)
            .clipShape(.buttonBorder)
            
            Button("Clear", action: {
                productName.removeAll()
                screenSize.removeAll()
                weight.removeAll()
                bag.removeAll()
                color.removeAll()
            })
            .padding()
            .frame(width: 80)
            .foregroundStyle(.red)
            .border(.red, width: 1)
            
            Spacer()
            
            
        })
        .padding(20)
    }
}

#Preview {
    ContentView()
}
