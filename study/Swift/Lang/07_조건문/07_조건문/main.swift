//
//  main.swift
//  07_조건문
//
//  Created by electrozone on 3/25/26.
//

import Foundation

let someInteger = 100

if someInteger < 100{
    print("100미만")
}else if someInteger > 100{
    print("100초과")
}else {
    print("100점")
}

var isCar = true
var isNew = true

if isCar, isNew{
    print("New Car")
}else{
    print("Old Car")
}

// Switch
let personAge = 14
if personAge < 1{
    print("baby")
}else if personAge < 3{
    print("toddler")
}else if personAge < 5{
    print("preschooler")
}else if personAge < 13{
    print("gradeschooler")
}else if personAge < 18{
    print("teen")
}else{
    print("adult")
}

switch personAge{
case 0..<1: print("baby")
case 1..<3: print("toddler")
case 3..<5: print("preschooler")
case 5..<13: print("gradeschooler")
case 13..<18: print("teen")
default: print("adult")
}

switch someInteger{
case 0: print("zero")
case 1..<100: print("1~99")
case 100: print("100")
case 101...Int.max: print("over 100")
default: print("unknown")
}

let anotherInteger: Character = "a"
switch anotherInteger{
case "a", "A": print("the latter A")
default: print("Not the letter A")
}

// Tuple과 Switch
let somePoint = (1,1)
switch somePoint{
case (0,0) : print("\(somePoint) is at the origin.")
case (_,0): print("\(somePoint) is on the x-axis.")
case (0,_): print("\(somePoint) is on the y-axis.")
case(-2...2, -2...2): print("\(somePoint) is inside the box.")
default: print("\(somePoint) is outside the box.")
}

// Exercise
let name = "유비"
let kor = 91
let eng = 97
let mat = 95

var tot = 0
var avg: Double = 0.0

tot = kor + eng + mat
avg = Double(tot) / 3.0

print("\(name)님의 총점은 \(tot)이고, 평균은 \(avg)입니다.")

// 평균 점수로 수우미양가 표시 (if문)
if avg >= 90.0{
    print("수")
}else if avg >= 80.0{
    print("우")
}else if avg >= 70.0{
    print("미")
}else if avg >= 50.0{
    print("양")
}else {
    print("가")
}

// 평균 점수로 수우미양가 표시 (switch문)
switch avg{
case 90.0...100.0: print("수")
case 80.0..<90.0: print("우")
case 70.0..<80.0: print("미")
case 60.0..<70.0: print("양")
default : print("가")
}

var grade: String
// 평균 점수로 수우미양가 표시 (삼항연산자로)
print(avg >= 90.0 ? "수" : (avg >= 80.0 ? "우" : (avg >= 70.0 ? "미" : (avg >= 50.0 ? "양" : "가"))))

// 선생님
grade = avg >= 90.0 ? "수" :
        avg >= 80.0 ? "우" :
        avg >= 70.0 ? "미" :
        avg >= 60.0 ? "양" : " 가"

// 점수 등급(수,우,미,양,가) 을 배열과 반복문으로 출력해보기
var score = [90, 80, 70, 60, 0]
var level: [String] = ["수","우","미","양","가"]

for i in 0..<score.count{
    if avg >= Double(score[i]){
        grade = level[i]
        break
    }
}
print(grade)
