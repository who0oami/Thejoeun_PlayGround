//
//  main.swift
//  03_기본연산자
//
//  Created by electrozone on 3/25/26.
//

import Foundation

// Tuple을 이용한 할당 연산자
let (x1, x2) = (1,2)
print(x1, x2)

// 사칙 연산자
print(1+2)
print(1-2)
print(1*2)
print(1/2) // 정수나눗셈
print(1%2) // 나머지
print(Double(1)/2) // 실수나눗셈

// 단항 음수 연산자
let one = 1
let minusOne = -one
let plusOne = -minusOne

// 관계 연산자
print((1, "zebra") < (2,"apple"))
print((2, "apple") < (2, "bird"))
print((4, "dog") == (4, "dog"))
print(("blue", -1) < ("purple",1))
//print(("blue", false) < ("purple",true)) 이건 안된다

// 삼항 조건 연산자
let contentHeight = 40
let hasHeader = true
let rowHeight = contentHeight + (hasHeader ? 50 : 20)
print(rowHeight)

// nill 병합 연산자
let defaultColorName = "red"
var userDefinedColorName: String? // Optional 변수
var colorNameToUes = userDefinedColorName ?? defaultColorName
print(colorNameToUes)

userDefinedColorName = "green"
colorNameToUes = userDefinedColorName ?? defaultColorName
print(colorNameToUes)

// 범위 연산자
for i in 1...10{
    print(i)
}

for i in 1..<10{ // 10 전까지
    print(i)
} // 반닫힌 범위 연산자

// 1부터 10까지의 합계 구하기
var sum: Int = 0
for i in 1...10{
    sum += i
}

print("1부터 10까지의 합계: \(sum)")

// 구구단 2단 부터 9단까지 출력
for dan in 2...9{
    for i in 1...9{
        print("\(dan) * \(i) = \(dan*i)")
    }
}

let names = ["Anna", "Alex", "Brian", "Jack"]
for name in names{
    print("Hello, \(name)!")
}

for i in 0..<names.count{
    print("Hello, \(names[i])!")
}

let a1 = [-1, -2, -3, 0, 1, 2, 3]
let b1 = a1[2...]
let c1 = a1[...2] // 2 번째 까지( 2표함)
print(b1)
print(c1)

let range = ...5
print(range.contains(3)) // 전에 데이터가 있니/없니 를 파악하는게 contains
print(range.contains(6))

// And or
let enterDoorCode = true
let presendRetinaScan = false

if enterDoorCode && presendRetinaScan{
    print("Welcome!")
}else{
    print("Access Denied")
}

if enterDoorCode || presendRetinaScan{
    print("Welcome")
}else{
    print("Access Denied")
}

// 사용자로 부터 입력 받기
print("Input your decimal number: " , terminator: "") // \n을 빼고 쓰겠다 -> terminator: ""
var inpNum = Int(readLine()!)

// if let 으로 optional 처리
if let repNum: Int = inpNum{
    print(repNum)
}else{
    print("Wrong Input")
}
