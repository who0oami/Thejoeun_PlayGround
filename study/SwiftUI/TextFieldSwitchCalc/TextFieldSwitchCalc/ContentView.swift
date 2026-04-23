//
//  ContentView.swift
//  TextFieldSwitchCalc
//
//  Created by electrozone on 3/27/26.
//

import SwiftUI

struct ContentView: View {
    private let buttonWidth: CGFloat = 140
    private let sectionSpacing: CGFloat = 28
    private let rowSpacing: CGFloat = 16
    private let buttonSpacing: CGFloat = 16
    private let buttonRowWidth: CGFloat = 296
    private let contentWidth: CGFloat = 248
    private let labelWidth: CGFloat = 92
    private let fieldWidth: CGFloat = 148
    private let toggleWidth: CGFloat = 108

    // 입력값과 스위치 상태를 화면에서 직접 관리합니다.
    @State private var firstField = ""
    @State private var secondField = ""
    @State private var addField = false
    @State private var subtractField = false
    @State private var multiplyField = false
    @State private var divideField = false
    // 계산 버튼을 눌렀을 때만 결과값을 저장합니다.
    @State private var addResult = ""
    @State private var subtractResult = ""
    @State private var multiplyResult = ""
    @State private var divideResult = ""

    private var firstNumber: Double {
        Double(firstField) ?? 0
    }

    private var secondNumber: Double {
        Double(secondField) ?? 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: sectionSpacing) {
            Text("간단한 계산기")
                .font(.title.bold())
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 32)

            VStack(spacing: rowSpacing) {
                inputRow(title: "첫번째 숫자 :", text: $firstField)
                inputRow(title: "두번째 숫자 :", text: $secondField)
            }
            .frame(width: contentWidth, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .center)

            HStack(spacing: buttonSpacing) {
                actionButton(title: "계산하기", color: .blue, action: calculateResults)
                actionButton(title: "지우기", color: .red, action: clearAll)
            }
            .frame(width: buttonRowWidth, alignment: .center)
            .frame(maxWidth: .infinity, alignment: .center)

            VStack(spacing: rowSpacing) {
                toggleRow(leftTitle: "덧셈", leftIsOn: $addField, rightTitle: "뺄셈", rightIsOn: $subtractField)
                toggleRow(leftTitle: "곱셈", leftIsOn: $multiplyField, rightTitle: "나눗셈", rightIsOn: $divideField)
            }
            .frame(width: contentWidth, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .center)

            VStack(spacing: rowSpacing) {
                resultRow(title: "덧셈 :", placeholder: "덧셈 결과", value: addField ? addResult : "")
                resultRow(title: "뺄셈 :", placeholder: "뺄셈 결과", value: subtractField ? subtractResult : "")
                resultRow(title: "곱셈 :", placeholder: "곱셈 결과", value: multiplyField ? multiplyResult : "")
                resultRow(title: "나눗셈 :", placeholder: "나눗셈 결과", value: divideField ? divideResult : "")
            }
            .frame(width: contentWidth, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .center)

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.white)
    }

    private func inputRow(title: String, text: Binding<String>) -> some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.headline)
                .frame(width: labelWidth, alignment: .leading)

            TextField("0", text: text)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .font(.title3)
                .multilineTextAlignment(.trailing)
                .frame(width: fieldWidth)
                .frame(height: 52)
        }
        .frame(width: contentWidth, alignment: .leading)
    }

    private func toggleRow(
        leftTitle: String,
        leftIsOn: Binding<Bool>,
        rightTitle: String,
        rightIsOn: Binding<Bool>
    ) -> some View {
        HStack {
            Toggle(leftTitle, isOn: leftIsOn)
                .frame(width: toggleWidth, alignment: .leading)

            Spacer()

            Toggle(rightTitle, isOn: rightIsOn)
                .frame(width: toggleWidth, alignment: .leading)
        }
        .frame(width: contentWidth, alignment: .leading)
    }

    private func actionButton(title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: buttonWidth)
                .frame(height: 52)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    private func resultRow(title: String, placeholder: String, value: String) -> some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.headline)
                .frame(width: labelWidth, alignment: .leading)

            TextField(placeholder, text: .constant(value))
                .textFieldStyle(.roundedBorder)
                .font(.title3)
                .multilineTextAlignment(.trailing)
                .frame(width: fieldWidth)
                .frame(height: 52)
                .disabled(true)
        }
        .frame(width: contentWidth, alignment: .leading)
    }

    private func calculateResults() {
        // 둘 중 하나라도 비어 있으면 계산하지 않고 결과를 유지하지 않습니다.
        guard !firstField.trimmingCharacters(in: .whitespaces).isEmpty,
              !secondField.trimmingCharacters(in: .whitespaces).isEmpty else {
            addResult = ""
            subtractResult = ""
            multiplyResult = ""
            divideResult = ""
            return
        }

        addResult = formattedNumber(firstNumber + secondNumber)
        subtractResult = formattedNumber(firstNumber - secondNumber)
        multiplyResult = formattedNumber(firstNumber * secondNumber)

        if secondNumber == 0 {
            divideResult = "0으로 나눌 수 없음"
        } else {
            divideResult = formattedNumber(firstNumber / secondNumber)
        }
    }

    private func clearAll() {
        firstField = ""
        secondField = ""
        addField = false
        subtractField = false
        multiplyField = false
        divideField = false
        addResult = ""
        subtractResult = ""
        multiplyResult = ""
        divideResult = ""
    }

    private func formattedNumber(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(value))
        }

        return String(format: "%.2f", value)
    }
}

#Preview {
    ContentView()
}
