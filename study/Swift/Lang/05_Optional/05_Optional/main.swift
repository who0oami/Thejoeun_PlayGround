//
//  main.swift
//  05_Optional
//
//  Created by electrozone on 3/25/26.
//

import Foundation

/*
 - 데이터가 있을수도 있고 없을 수도 있다.
 - nil 값을 포함할 수 도 있고 안할 수 도 있다.
 */

// 암시적 추출 옵셔놀 : Forced Unweapping(메모리 체크없이 무조건 Unwrapping)
let constantNum = 100
var optionalNum: Int? = nil // 정의 할때 보통 물음표를 많이 쓰고
// let optionalNum: Int! = nil // 해제 할때 보통 느낌표를 많이 쓴다
optionalNum = 100
print(optionalNum!) // optional 을 벗겨내는 거
print(optionalNum! + 10) // optional 을 벗겨내는 거

// Optional Unwrapping
// nil check + 안전한 추출값 추출 (memory에 변수의 값이 있는지 없는지를 확인하고 추출한다)

var myName: String? = nil // 초기값
myName = "apple"
if let name = myName {
    print("Hello, \(name)")
} else {
    print("nil")
}

var myName2: String? = "James" // 물음표가 없으면 nil 데이터를 넣을 수 없음
var yourName2: String? = nil

if let name2 = myName2, let friend = yourName2 {
    print(" \(name2) and \(friend)")
}else{
    print("nil")
}

// guard let
func multiplyByTen(value: Int?){
    guard let number = value, number < 10 else { // value 들어온 값을 number로 넘겨줘서 확인 하는 거
        return
    }
    
    let result = number * 10
    print(result)
}


//multiplyByTen(value: 5)
multiplyByTen(value: nil)
