//
//  Calc.swift
//  Quiz02
//
//  Created by electrozone on 3/26/26.
//

import Foundation

extension ContentView {
    func calculateResult(first: String, second: String) -> CalculationOutput {
        guard !first.isEmpty, !second.isEmpty else {
            return .init(result: .empty, message: "두 개의 숫자를 모두 입력하세요.")
        }

        guard let firstValue = Int(first), let secondValue = Int(second) else {
            return .init(result: .empty, message: "숫자만 입력하세요.")
        }

        return .init(
            result: .init(
                addition: "\(firstValue + secondValue)",
                subtraction: "\(firstValue - secondValue)",
                multiplication: "\(firstValue * secondValue)",
                division: Self.divisionText(first: firstValue, second: secondValue)
            ),
            message: "계산이 완료 되었습니다."
        )
    }

    private static func divisionText(first: Int, second: Int) -> String {
        guard second != 0 else {
            return "0으로 나눌 수 없음"
        }

        return formatted(Double(first) / Double(second))
    }

    private static func formatted(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 8
        formatter.minimumFractionDigits = 0

        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
