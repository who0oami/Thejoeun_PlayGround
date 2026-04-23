//
//  main.swift
//  01_상수와 변수
//
//  Created by electrozone on 3/25/26.
//

import Foundation

print("Hello, World!")
print("안녕하세요")
print(12345)

print("123 + 456" , 123 + 456)
print("😘")

// 변수 작성 규칙
// studentName : Camel
// StudentName : Pascal
// student_name : Snake
// 첫 글자를 숫자나 특수문자로 시작하면 안되나 _는 사용가능

// 상수를 사용하여 출력하기
let message = "Hello World!"
print(message)

// 변수를 사용하여 출력하기
var message1 = "Hello World"
message1 += "안녕하세요" // 바꿔줄수 있는 걸로 만드는게 var
// message = 10 (이건 안된다
print(message1)

// 변수 선언 방법
let intLetNum1: Int = 200
var strVarStr1: String = "abc"

// 상수 선언후에 나중에 값 할당하기
let inputA = 100
let inputB = 200
let sum: Int

sum = inputA + inputB
print(sum)

// 한줄에 동시 선언
var aNum = 10, bNum=20

// String Interpolation ( 문자열 보강법 )
let age: Int = 10

print("저는 \(age)살입니다.") // \(age) -> 이게 fstring 임 중괄호 같은 역할
print("저의 형은\(age+4)살 입니다.")

