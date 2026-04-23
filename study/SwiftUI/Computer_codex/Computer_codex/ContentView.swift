//
//  ContentView.swift
//  Computer_codex
//
//  Created by electrozone on 3/26/26.
//

import SwiftUI

struct ContentView: View {
    @State private var productNameInput = ""
    @State private var screenSizeInput = ""
    @State private var weightInput = ""
    @State private var bagInput = ""
    @State private var colorInput = ""

    @State private var productName = ""
    @State private var screenSize = ""
    @State private var weight = ""
    @State private var bag = ""
    @State private var color = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Computer 사양")
                .bold()
                .padding(.bottom, 30)

            VStack(spacing: 14) {
                TextFieldRowView(title: "제품명 :", displayText: productName, text: $productNameInput, placeholder: "제품명을 입력하세요")
                TextFieldRowView(title: "화면크기 :", displayText: screenSize, text: $screenSizeInput, placeholder: "화면크기를 입력하세요")
                TextFieldRowView(title: "무게 :", displayText: weight, text: $weightInput, placeholder: "무게를 입력하세요")
                TextFieldRowView(title: "가방 :", displayText: bag, text: $bagInput, placeholder: "가방유무를 입력하세요")
                TextFieldRowView(title: "색상 :", displayText: color, text: $colorInput, placeholder: "색상을 입력하세요")
            }

            OKButtonView {
                applyInputs()
            }
            .padding(.top, 10)

            ClearButtonView {
                clearFields()
            }

            Spacer()
        }
        .padding(20)
    }

    private func applyInputs() {
        let productNameValue: String = "맥북프로"
        let screenSizeValue: Int = 14
        let weightValue: Double = 1.63
        let bagValue: Bool = false
        let colorValue: Character = "백"

        productNameInput = productNameValue
        screenSizeInput = String(screenSizeValue)
        weightInput = String(weightValue)
        bagInput = String(bagValue)
        colorInput = String(colorValue)

        productName = productNameValue
        screenSize = String(screenSizeValue)
        weight = String(weightValue)
        bag = String(bagValue)
        color = String(colorValue)
    }

    private func clearFields() {
        productNameInput = ""
        screenSizeInput = ""
        weightInput = ""
        bagInput = ""
        colorInput = ""

        productName = ""
        screenSize = ""
        weight = ""
        bag = ""
        color = ""
    }
}

#Preview {
    ContentView()
}
