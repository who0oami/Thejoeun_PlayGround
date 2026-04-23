//
//  ContentView.swift
//  Quiz05
//
//  Created by electrozone on 3/27/26.
//

import Foundation
import SwiftUI

struct ContentView: View {
    @FocusState private var isTextFieldFocused: Bool
    @State private var inputDan = ""
    @State private var gugudanResult = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("구구단 출력")
                .font(.title3)
                .bold()

            HStack {
                TextField("구구단", text: $inputDan)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 140)
                    .keyboardType(.numberPad)
                    .focused($isTextFieldFocused)

                Button("단출력") {
                    printGugudan()
                }
                .buttonStyle(.borderedProminent)
            }

            ScrollView {
                Text(gugudanResult)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(.black)
                    .padding(12)
            }
            .frame(width: 240, height: 220)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.5))
            )
        }
        .padding(24)
    }

    private func printGugudan() {
        let trimmedDan = inputDan.trimmingCharacters(in: .whitespacesAndNewlines)

        if let dan = Int(trimmedDan), dan > 0 {
            gugudanResult = (1...9)
                .map { "\(dan) x \($0) = \(String(format: "%2d", dan * $0))" }
                .joined(separator: "\n")
        } else {
            gugudanResult = "출력할 단을 숫자로 입력하세요."
        }

        isTextFieldFocused = false
    }
}

#Preview {
    ContentView()
}
