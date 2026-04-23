//
//  ContentView.swift
//  Quiz02
//
//  Created by electrozone on 3/26/26.
//

import SwiftUI

struct ContentView: View {
    @State private var firstNumber = ""
    @State private var secondNumber = ""
    @State private var calculationResult = CalculationResult.empty
    @State private var message = "숫자 연산 입니다."
    @FocusState private var focusedField: Field?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundDismissLayer

                ViewThatFits(in: .vertical) {
                    content(metrics: .regular)
                    content(metrics: .compact)
                    ScrollView(showsIndicators: false) {
                        content(metrics: .compact)
                    }
                    .scrollDismissesKeyboard(.interactively)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()

                Button("완료") {
                    dismissKeyboard()
                }
            }
        }
    }

    @ViewBuilder
    private func content(metrics: LayoutMetrics) -> some View {
        VStack(spacing: 0) {
            Spacer(minLength: metrics.topSpacing)

            Text("두개의 숫자 연산")
                .font(metrics.titleFont)
                .fontWeight(.semibold)
                .minimumScaleFactor(0.85)

            Spacer(minLength: metrics.titleBottomSpacing)

            inputSection(metrics: metrics)

            actionSection(metrics: metrics)

            Spacer(minLength: metrics.middleSpacing)

            resultSection(metrics: metrics)

            Text(message)
                .font(metrics.messageFont)
                .foregroundStyle(.secondary)
                .padding(.top, metrics.messageTopSpacing)

            Spacer(minLength: metrics.bottomSpacing)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    @ViewBuilder
    private func inputSection(metrics: LayoutMetrics) -> some View {
        VStack(spacing: metrics.rowSpacing) {
            inputRow(
                title: "첫번째 숫자 :",
                text: filteredBinding(text: $firstNumber),
                placeholder: "1st Number",
                field: .first,
                metrics: metrics
            )

            inputRow(
                title: "두번째 숫자 :",
                text: filteredBinding(text: $secondNumber),
                placeholder: "2nd Number",
                field: .second,
                metrics: metrics
            )
        }
    }

    @ViewBuilder
    private func actionSection(metrics: LayoutMetrics) -> some View {
        VStack(spacing: metrics.buttonSpacing) {
            Button("계산하기") {
                calculate()
            }
                .font(metrics.buttonFont)
                .fontWeight(.semibold)

            Button("초기화") {
                reset()
            }
                .font(metrics.buttonFont)
                .foregroundStyle(.blue.opacity(0.7))
        }
        .padding(.top, metrics.actionTopSpacing)
    }

    @ViewBuilder
    private func resultSection(metrics: LayoutMetrics) -> some View {
        VStack(spacing: metrics.resultSpacing) {
            resultRow(title: "덧셈 결과 :", value: calculationResult.addition, metrics: metrics)
            resultRow(title: "뺄셈 결과 :", value: calculationResult.subtraction, metrics: metrics)
            resultRow(title: "곱셈 결과 :", value: calculationResult.multiplication, metrics: metrics)
            resultRow(title: "나눗셈 결과 :", value: calculationResult.division, metrics: metrics)
        }
    }

    @ViewBuilder
    private func inputRow(
        title: String,
        text: Binding<String>,
        placeholder: String,
        field: Field,
        metrics: LayoutMetrics
    ) -> some View {
        HStack(spacing: 12) {
            Text(title)
                .font(metrics.labelFont)
                .fontWeight(.semibold)
                .frame(width: metrics.labelWidth, alignment: .leading)
                .fixedSize(horizontal: true, vertical: false)

            TextField(placeholder, text: text)
                .textFieldStyle(.roundedBorder)
                .font(metrics.fieldFont)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .focused($focusedField, equals: field)
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func resultRow(title: String, value: String, metrics: LayoutMetrics) -> some View {
        HStack(spacing: 12) {
            Text(title)
                .font(metrics.labelFont)
                .fontWeight(.semibold)
                .frame(width: metrics.labelWidth, alignment: .leading)
                .fixedSize(horizontal: true, vertical: false)

            TextField("", text: .constant(value))
                .textFieldStyle(.roundedBorder)
                .font(metrics.fieldFont)
                .multilineTextAlignment(.trailing)
                .disabled(true)
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func filteredBinding(text: Binding<String>) -> Binding<String> {
        Binding(
            get: {
                text.wrappedValue
            },
            set: { newValue in
                text.wrappedValue = newValue.filter(\.isNumber)
            }
        )
    }

    private func calculate() {
        let output = calculateResult(first: firstNumber, second: secondNumber)
        calculationResult = output.result
        message = output.message
        dismissKeyboard()
    }

    private func reset() {
        firstNumber = ""
        secondNumber = ""
        calculationResult = .empty
        message = "숫자 연산 입니다."
        dismissKeyboard()
    }

    private func dismissKeyboard() {
        focusedField = nil
    }

    private var backgroundDismissLayer: some View {
        Color.clear
            .contentShape(Rectangle())
            .onTapGesture {
                dismissKeyboard()
            }
    }
}

extension ContentView {
    struct CalculationResult {
        let addition: String
        let subtraction: String
        let multiplication: String
        let division: String

        static let empty = CalculationResult(
            addition: "",
            subtraction: "",
            multiplication: "",
            division: ""
        )
    }

    struct CalculationOutput {
        let result: CalculationResult
        let message: String
    }

    enum Field {
        case first
        case second
    }

    struct LayoutMetrics {
        let topSpacing: CGFloat
        let titleBottomSpacing: CGFloat
        let actionTopSpacing: CGFloat
        let middleSpacing: CGFloat
        let bottomSpacing: CGFloat
        let rowSpacing: CGFloat
        let resultSpacing: CGFloat
        let buttonSpacing: CGFloat
        let labelWidth: CGFloat
        let titleFont: Font
        let labelFont: Font
        let fieldFont: Font
        let buttonFont: Font
        let messageFont: Font
        let messageTopSpacing: CGFloat

        static let regular = LayoutMetrics(
            topSpacing: 24,
            titleBottomSpacing: 32,
            actionTopSpacing: 22,
            middleSpacing: 44,
            bottomSpacing: 24,
            rowSpacing: 18,
            resultSpacing: 14,
            buttonSpacing: 16,
            labelWidth: 110,
            titleFont: .headline,
            labelFont: .body,
            fieldFont: .body,
            buttonFont: .body,
            messageFont: .body,
            messageTopSpacing: 28
        )

        static let compact = LayoutMetrics(
            topSpacing: 8,
            titleBottomSpacing: 16,
            actionTopSpacing: 16,
            middleSpacing: 24,
            bottomSpacing: 8,
            rowSpacing: 12,
            resultSpacing: 10,
            buttonSpacing: 12,
            labelWidth: 102,
            titleFont: .subheadline,
            labelFont: .subheadline,
            fieldFont: .subheadline,
            buttonFont: .subheadline,
            messageFont: .footnote,
            messageTopSpacing: 20
        )
    }
}

#Preview {
    ContentView()
}
