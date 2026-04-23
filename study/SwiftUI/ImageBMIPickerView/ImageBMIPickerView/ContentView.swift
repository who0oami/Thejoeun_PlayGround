//
//  ContentView.swift
//  ImageBMIPickerView
//
//  Created by electrozone on 3/30/26.
//

import SwiftUI

struct ContentView: View {
    // 사용자가 선택하는 신장과 몸무게 값을 상태로 관리합니다.
    @State private var selectedHeight: Int = 170
    @State private var selectedWeight: Int = 70

    // 계산 버튼을 눌렀을 때만 결과 문장과 결과 이미지를 보이도록 상태를 따로 관리합니다.
    @State private var bmiResultText: String = ""
    @State private var selectedResultImageName: String = ""
    @State private var hasCalculatedBMI: Bool = false

    // Picker에 사용할 범위를 미리 만들어 두면 body가 더 읽기 쉬워집니다.
    private let heightRange = Array(100...200)
    private let weightRange = Array(50...200)

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("BMI 측정기")
                    .font(.largeTitle.bold())
                    .padding(.top, 30)

                HStack(spacing: 20) {
                    pickerSection(title: "신장(Cm)", selection: $selectedHeight, values: heightRange)
                    pickerSection(title: "몸무게(Kg)", selection: $selectedWeight, values: weightRange)
                }
                .padding(.horizontal)

                Button(action: updateBMIResult) {
                    Text("계산하기")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 14)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                if hasCalculatedBMI {
                    Text(bmiResultText)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                bmiImageSection
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // 공통 Picker UI를 함수로 분리하면 같은 코드를 반복하지 않아도 됩니다.
    private func pickerSection(title: String, selection: Binding<Int>, values: [Int]) -> some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.headline)

            Picker(title, selection: selection) {
                ForEach(values, id: \.self) { value in
                    Text("\(value)")
                        .tag(value)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 180)
            .clipped()
        }
        .frame(width: 110)
    }

    // 계산 전에는 기본 기준표 이미지를 보여주고, 계산 후에는 상태에 맞는 결과 이미지로 바꿉니다.
    private var bmiImageSection: some View {
        Image(hasCalculatedBMI ? selectedResultImageName : "bmi")
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .frame(height: 180)
    }

    // 버튼을 눌렀을 때만 BMI를 계산하고, 결과 문장과 결과 이미지를 함께 갱신합니다.
    private func updateBMIResult() {
        let bmiValue = calculateBMI(height: selectedHeight, weight: selectedWeight)
        let category = bmiCategory(for: bmiValue)

        bmiResultText = String(format: "귀하의 bmi 지수는 %.2f고 %@ 입니다.", bmiValue, category)
        selectedResultImageName = arrowImageName(for: bmiValue)
        hasCalculatedBMI = true
    }

    // BMI 공식만 담당하는 함수입니다.
    private func calculateBMI(height: Int, weight: Int) -> Double {
        let heightInMeter = Double(height) / 100.0
        return Double(weight) / (heightInMeter * heightInMeter)
    }

    // BMI 수치에 맞는 판정 문구를 반환합니다.
    private func bmiCategory(for bmi: Double) -> String {
        switch bmi {
        case ..<18.5:
            return "저체중"
        case 18.5..<23.0:
            return "정상체중"
        case 23.0..<25.0:
            return "과체중 위험"
        case 25.0..<30.0:
            return "비만"
        default:
            return "고도비만"
        }
    }

    // BMI 수치에 맞는 결과 이미지 이름을 반환합니다.
    private func arrowImageName(for bmi: Double) -> String {
        switch bmi {
        case ..<18.5:
            return "underweight"
        case 18.5..<23.0:
            return "normal"
        case 23.0..<25.0:
            return "risk"
        case 25.0..<30.0:
            return "overweight"
        default:
            return "obese"
        }
    }
}

#Preview {
    ContentView()
}
