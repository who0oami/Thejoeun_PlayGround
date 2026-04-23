//
//  main.swift
//  14_Extension
//
//  Created by electrozone on 3/26/26.
//

import Foundation

// Extension
// Extension은 struct, class 타입에 새로운 기능을 추가할 수 있는 기능

// 기존 소스 그래도 두고 내것만 추가할때 쓰는거
extension Int {
    var isEven: Bool {
        return self%2 == 0
    }
    var isOdd: Bool {
        return self%2 == 1
    }
}

print(1.isEven)
var num: Int = 3
print(num.isOdd)
