//
//  main.swift
//  09_함수
//
//  Created by electrozone on 3/25/26.
//

import Foundation


func integerSum(num1: Int, num2: Int) -> Int{
    return num1 + num2
}

print(integerSum(num1:3, num2:4))

func integerSum1(_ num1: Int, _ num2: Int) -> Int{
    return num1 + num2
}
print(integerSum1(2,3))

func integerSum2(숫자1 num1: Int, 숫자2 num2: Int) -> Int{
    return num1 + num2
}

print(integerSum2(숫자1: 10, 숫자2: 20))

// 기본값

func greeting(friend: String, me: String="조조"){
    print("Hello, \(friend)! I'm \(me).")
}

greeting(friend: "유비")
greeting(friend: "장비", me: "유비")


// Ex
// 시작 숫자부터 끝 숫자의 합계를 구하는 함수 만들기
print(addRange(start:1, end: 100))

func addRange(start: Int, end: Int) -> Int{
    var sum: Int = 0
    for i in start...end{
        sum += i
    }
    print("\(start)부터 \(end)의 합은 \(sum) 입니다.")
    return sum
}

// 1부터 100까지의 합은 5050 입니다.

// 선생님 정답

func addRange2(start: Int, end: Int) -> String{
    var sum: Int = 0
    for i in start...end{
        sum += i
    }
    return "\(start)부터 \(end)까지의 합은 \(sum) 입니다."
}

// Ex
// 해당 범위의 짝수와 홀수를 판단하여 합계를 구하는 함수 만들기
func isMatch(type: String, number: Int) -> Bool {
    if type == "even" {
        return number % 2 == 0
    }

    if type == "odd" {
        return number % 2 != 0
    }

    return false
}

func decisionRange1(type: String, start: Int, end: Int) -> Int {
    let lower = min(start, end)
    let upper = max(start, end)
    var sum = 0

    for number in lower...upper {
        if isMatch(type: type, number: number) {
            sum += number
        }
    }

    return sum
}

func decisionRange2(type: String, start: Int, end: Int) -> String {
    if type != "even" && type != "odd" {
        return "입력된 항목이 잘못 되었습니다."
    }

    let sum = decisionRange1(type: type, start: start, end: end)
    let kind = type == "even" ? "짝수" : "홀수"
    return "\(start)부터 \(end)까지의 수중 \(kind)의 합은 \(sum)입니다."
}


// ---
print("1부터 10까지의 수중 짝수의 합은 \(decisionRange1(type: "even", start: 1, end: 10))입니다.")
print("1부터 10까지의 수중 홀수의 합은 \(decisionRange1(type: "odd", start: 1, end: 10))입니다.")

print(decisionRange2(type: "even", start: 1, end: 10))
print(decisionRange2(type: "odd", start: 1, end: 10))
print(decisionRange2(type: "abc", start: 1, end: 10))
print(decisionRange2(type: "even", start: 10, end: 1))

// 1부터 20까지의 수중 짝수의 합은 30 입니다
// 1부터 20까지의 수중 홀수의 합은 25 입니다
// 입력된 항목이 잘못 되었습니다.

/*
 -------
 */

func checkNumberType(type: String, number: Int) -> Bool {
    if type == "even" {
        return number % 2 == 0
    }
    if type == "odd" {
        return number % 2 != 0
    }

    return false
}

func decisionRange3(type: String, start: Int, end: Int) -> Int {
    let lower = min(start, end)
    let upper = max(start, end)
    var sum = 0

    for number in lower...upper {
        if checkNumberType(type: type, number: number) {
            sum += number
        }
    }

    return sum
}

func decisionRange4(type: String, start: Int, end: Int) -> String {
    if type != "even" && type != "odd" {
        return "입력된 항목이 잘못 되었습니다."
    }

    let kind = type == "even" ? "짝수" : "홀수"
    let sum = decisionRange3(type: type, start: start, end: end)
    return "\(start)부터 \(end)까지의 수중 \(kind)의 합은 \(sum)입니다."
}

print(decisionRange4(type: "even", start: 1, end: 10))
print(decisionRange4(type: "odd", start: 1, end: 10))
print(decisionRange4(type: "abc", start: 1, end: 10))
print(decisionRange4(type: "even", start: 10, end: 1))


// Overloading : 함수의 이름은 중복되도 매개변수의 갯수로 구분이 가능

// 도형의 면적, 둘레를 구하는 함수(원, 직사각형, 직각삼각형)

func shape(_ r: Double){
    let pi=3.14159
    let area=pi*r*r
    let border=2*pi*r
    print("원의 면적 : \(area), 둘레 : \(border)")
}


func shape(_ w: Double, _ h: Double){
    let area=w*h
    let border=2*(w+h)
    print("넓이: \(area), 둘레 : \(border)")
}

func shape(_ w: Int, _ h: Int, _ l: Int){
    let area = w*h/2
    let border = w+h+l
    print("넓이: \(area), 둘레 : \(border)")
}

shape(3)
shape(5, 6)
shape(5, 6, 7)

// 여러개의 return value
func sizeConverter(_ length: Float) -> (yards: Float, centimeter: Float, meter: Float){
    let yards = length * 0.0277778
    let centimeter = length * 2.54
    let meter = length * 0.0254
    
    return (yards, centimeter, meter)
}

let lengthTuples = sizeConverter(20)
print(lengthTuples)
print(lengthTuples.meter)

// 가변인자

func mean(score:Int...) -> Double{
    var total = 0
    for i in score{
        total += i
    }
    return Double(total) / Double(score.count)
}

print(mean(score: 10, 20, 30))
print(mean(score: 10, 20, 30, 40, 50))
