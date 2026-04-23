//
//  ContentView.swift
//  Quiz03
//
//  Created by electrozone on 3/26/26.
//

import SwiftUI

struct ContentView: View {
    @State private var firstNumber = ""
    @State private var secondNumber = ""
    @State private var message = "환영 합니다."
    @FocusState private var focusedField: InputField?

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    Spacer(minLength: 180)

                    Text("짝수인 경우에만 덧셈 실행")
                        .font(.headline)

                    VStack(spacing: 16) {
                        inputRow(title: "1번숫자 :", value: $firstNumber, field: .first)
                        inputRow(title: "2번숫자 :", value: $secondNumber, field: .second)
                    }

                    Button("판별하기") {
                        focusedField = nil
                        validateAndCalculate()
                    }
                    .fontWeight(.semibold)

                    Text(message)
                        .padding(.top, 12)

                    Spacer(minLength: 180)
                }
                .frame(maxWidth: .infinity, minHeight: geometry.size.height - 32)
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = nil
            }
        }
    }

    private func validateAndCalculate() {
        if let first = Int(firstNumber), let second = Int(secondNumber) {
            if first.isMultiple(of: 2) && second.isMultiple(of: 2) {
                message = "입력하신 숫자의 합은 \(first + second) 입니다."
            } else {
                message = "짝수를 입력하세요"
            }
        } else {
            message = "숫자를 입력하세요"
        }
    }

    private func inputRow(title: String, value: Binding<String>, field: InputField) -> some View {
        HStack(spacing: 10) {
            Text(title)
                .fontWeight(.semibold)

            TextField("숫자입력", text: value)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .frame(width: 90)
                .focused($focusedField, equals: field)
        }
    }
}

private extension ContentView {
    enum InputField {
        case first
        case second
    }
}

#Preview {
    ContentView()
}
