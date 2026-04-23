//
//  main.swift
//  Ex01
//
//  Created by electrozone on 3/25/26.
//

import Foundation

/*
 Input your decimal no. :5
 *
 **
 ***
 ****
 *****
 ****
 ***
 **
 *
 
 */

print("Input your decimal number: ", terminator: "")
let input = readLine()

if let input,
   let repNum = Int(input),
   (1...10).contains(repNum) {
    for i in 1...repNum {
        print(String(repeating: "*", count: i))
    }

    if repNum > 1 {
        for i in stride(from: repNum - 1, through: 1, by: -1) {
            print(String(repeating: "*", count: i))
        }
    }
}

// 1의 10승 부터 10의 10승까지의 제곱승을 구하라
/*
 
 
 */
for number in UInt(1)...UInt(10) {
    var result: UInt = 1

    for _ in 1...10 {
        result *= number
    }

    print(result)
}

// 선생님 버전
var dispNum: Double = 1.0

for _ in 0...10{
    print(String(format: "%12.0f", dispNum))
    dispNum*=10
}

/*
 Input your decimal no. :4
 
 4's factorial value = 24
 */
print("Input your decimal no. :", terminator: "")
let factorialInput = readLine()

if let factorialInput,
   let number = UInt(factorialInput) {
    var factorialValue: UInt = 1

    for value in 1...number {
        factorialValue *= value
    }

    print("\(number)'s factorial value = \(factorialValue)")
}

// 더 간단한 버전
print("Input your decimal no. :", terminator: "")

if let simpleInput = readLine(),
   let number = UInt(simpleInput) {
    let factorialValue = (1...number).reduce(1, *)
    print("\(number)'s factorial value = \(factorialValue)")
}

// for문으로 누적해서 계산하는 버전
print("Input your decimal no. :", terminator: "")

if let forInput = readLine(),
   let number = UInt(forInput) {
    var total: UInt = 1

    for value in 1...number {
        total = total * value
    }

    print("\(number)'s factorial value = \(total)")
}

// 선생님 버전
var resultNum = 1
print("Input your decimal no. :", terminator: "")
var inpNum = Int(readLine()!)

if let repNum: Int = inpNum {
    action(repNum: repNum)
}else{
    print("Wrong No.")
}

// 함수
func action(repNum: Int){
    for i in 1...repNum{
        resultNum *= i
    }
    print("\(repNum)'s factorial value = \(resultNum)")
}
