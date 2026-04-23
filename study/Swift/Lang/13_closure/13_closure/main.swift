//
//  main.swift
//  13_closure
//
//  Created by electrozone on 3/26/26.
//

import Foundation

// function
func sumFunction(num1: Int, num2: Int) -> Int {
    return num1 + num2
}

var sumResult: Int = sumFunction(num1: 10, num2: 20)
print(sumResult)

// closure
var sumColsure = {
    (num1: Int, num2: Int) -> Int in
    return num1 + num2
}

sumResult = sumColsure(10, 20)
print(sumResult)
