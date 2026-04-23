//
//  main.swift
//  12_enumerte
//
//  Created by electrozone on 3/26/26.
//

import Foundation

enum Temperature{
    case hot
    case warm
    case cold
}

func displayTemperature(_ temp:Temperature){
    switch temp {
    case .hot:
        print("It is hot")
    case .warm:
        print("It is warm")
    case .cold:
        print("It is cold")
    }
}

func displayTempInpo(temp:Temperature){
    
}

displayTempInfo(temp: .hot)

enum ArithmeticOperation{
    case addition
    case subtration
    case multiplication
    case division
    
    // 연산을 수행하는 함수
    func perform(_ num1: Double, _ num2: Double) -> Double {
        switch self{
        case .addition:
            return num1 + num2
        case .subtration:
            return num1 - num2
        case .multiplication:
            return num1 * num2
        case .division:
            if num2 != 0{
                return num1 / num2
            }else{
                return Double.nan
            }
            
        }
    }
}

// Enum 연산 사용
let operation:ArithmeticOperation = .addition
let result = operation.perform(3.0, 4.0)
print("3 + 4 = \(result)")

let operation1:ArithmeticOperation = .division
let result1 = operation1.perform(3.0, 0)
print("3 + 4 = \(result)")

