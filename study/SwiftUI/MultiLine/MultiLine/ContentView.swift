//
//  ContentView.swift
//  MultiLine
//
//  Created by electrozone on 3/27/26.
//

import SwiftUI

struct ContentView: View {
    @FocusState var isTextFieldFocused: Bool
    @State var inputText = ""
    @State var enteredText = ""
    
    var body: some View {
        VStack {
            Text("TextEditor를 이용한 여러 Line 출력")
                .bold()
                .padding()
            HStack(content: {
                TextField("문자입력", text: $inputText)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 200)
                    .multilineTextAlignment(.leading) // 글씨방향
                    .keyboardType(.default)
                    .focused($isTextFieldFocused)
                
                Button("추가", action: {
                    let textCheck = inputText.trimmingCharacters(in:
                            .whitespacesAndNewlines)
                    if !textCheck.isEmpty {
                        enteredText += inputText + "\n"
                    }
                    inputText = ""
                    isTextFieldFocused = false
                })
            })
            // 나중에 스크롤 되게 바꿔보기
            TextEditor(text: $enteredText)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .foregroundStyle(.black).bold()
                .colorMultiply(.gray.opacity(0.7)) // 색곱하기 _ 덧칠한다 생각하면 된다_ opacity(0.7)-> 투명도 조절
                .disabled(true)
                .padding()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
