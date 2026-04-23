//
//  ContentView.swift
//  Calc
//
//  Created by electrozone on 3/27/26.
//

import SwiftUI

struct ContentView: View {
    @FocusState var isTextFieldFocused: Bool
    @State var firstNum = ""
    @State var secondNum = ""
    @State var result = ""
    
    var body: some View {
        VStack {
          Text("클래스를 통한 덧셈 계산")
                .bold()
                .padding(.bottom, 80)
            HStack{
                Text("첫번째 숫자")
                TextField("0",text: $firstNum)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 100)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numberPad)
                    .focused(($isTextFieldFocused))
            }
            HStack{
                Text("두번째 숫자")
                TextField("0",text: $secondNum)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 100)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numberPad)
                    .focused(($isTextFieldFocused))
            }
            
            Button("Add", action: {
                // 입력을 안하였을 경우 기본값 0으로 대체
                let num1 = Int(firstNum) ?? 0
                let num2 = Int(secondNum) ?? 0
                
                let addition = Addition()
                result = String(addition.add(num1, num2))
                isTextFieldFocused = false
            })
            .frame(width: 120, height: 40)
            .background(.blue)
            .foregroundStyle(.white)
            .clipShape(.buttonBorder)
            .padding()
            
            ZStack(content: {
                Color.gray.ignoresSafeArea(edges: .all)
                Text(result)
                    .bold()
            })
            .frame(width: 300, height: 50)
            
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
