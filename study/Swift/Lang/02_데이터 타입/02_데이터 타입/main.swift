//
//  main.swift
//  02_데이터 타입
//
//  Created by electrozone on 3/25/26.
//

import Foundation

print("Int  : \(Int.min) ~\(Int.max)")
print("Int  : \(UInt.min) ~\(UInt.max)")
print("Int8  : \(Int8.min) ~\(Int8.max)")
print("Int16  : \(Int16.min) ~\(Int16.max)")
print("Int32  : \(Int32.min) ~\(Int32.max)")
print("Int64  : \(Int64.min) ~\(Int64.max)") // 기본값은 이거
print("Double  : \(-Double.greatestFiniteMagnitude) ~\(Double.greatestFiniteMagnitude)")
print("Float  : \(-Float.greatestFiniteMagnitude) ~\(Float.greatestFiniteMagnitude)")

// 기본 데이터 타입

// Bool
var someBool: Bool = true
someBool = false

// Int
var someInt: Int = -100
someInt = 100
someInt = 100_000 // 천단위 쉼표와 같은 기능이라 생각하면 된다 , 파이썬에서도 이거 가능

// UInt
var someUInt: UInt = 100

// Float
var someFloat: Float = 3.14

// Double
var someDouble: Double = 3.14

// type
print(type(of: someDouble))

// 숫자 Type 변환
let doubleNum =  4.999999
var castToInt = Int(doubleNum)
var rountToInt = Int(doubleNum.rounded())
print("Origin : \(doubleNum), Cast 1: \(castToInt), Round 1: \(rountToInt)")

// Charater
var someCharaacter: Character = "A"

// String
var someString: String = "Hello, World!"
someString = someString + "안녕하세요"
print(someString)

someString = """
12345
    abcde
        가나다라마
"""
print(someString)

// 문자열과 특수문자
print("aa\t\tbb\n\ncc")

let wiseWords = "\"Imagination is more important than knowledge.\" - Albert Einstein"
print(wiseWords)

var emptyString = ""
var anotherEmptyString = String() // string 안에 아무것도 없는 걸 상속받은 거 _ string 이 클라스 객체형 언어이기 때문에
var emptyString1 : String

if emptyString.isEmpty {
    print("Nothing to see here.")
}

// 문자배열을 이용한 문자열 출력
let catCharacters: [Character] = ["C", "a", "t"]
var catString = String(catCharacters)
catString.append("!")
print(catString)

let str = "12345,6789"
print("str has \(str.count) characters")

if str.count == 0{
    print("Data가 없습니다.")
}else{
    print("Data는 \(str) 입니다.")
}

let multiplier = 3
print("\(multiplier) times 2.5 is \(Double(multiplier) * 2.5)")

// 문자열 인덱스
let greeting = "Guten Tag!"
print(greeting[greeting.startIndex])
print(greeting[greeting.index(before: greeting.endIndex)])
print(greeting[greeting.index(after: greeting.startIndex)])
print(greeting[greeting.index(greeting.startIndex, offsetBy: 7)])

// Any, nil
// Any : Swift의 모든 Type을 저장하는 키워드
// nil : 없음을 의미 (null이라 생각해도 된다 )

//Any

var someAny: Any = 100
someAny = "Hello"
someAny = 123.12

var someAny1: Double = 234.56
print(someAny as! Double + someAny1)

// Tuple
var country = (82,"KR", "Korea")
print("Country code: \(country.0), Country Name: \(country.1), Country Full Name: \(country.2)")

var country1 = (countryCode: 82, countryName: "KR", countryFullName: "Korea")
print("\(country1.countryCode)")

// Tuple을 사용하여 직사각형의 넓이와 둘레 구현
typealias Rectangle = (name: String, w: Int, h: Int, area: Int, border: Int)

var r1: Rectangle = ("직사각형1", 5, 6, 0, 0)
var r2: Rectangle = ("직사각형2", 15, 7, 0, 0)

r1.area = r1.w * r1.h
r1.border = 2 * (r1.w + r1.h)
print(r1)

r2.area = r2.w * r2.h
r2.border = 2 * (r2.w + r2.h)
print(r2)

