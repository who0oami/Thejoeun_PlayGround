//
//  main.swift
//  08_반복문
//
//  Created by electrozone on 3/25/26.
//

import Foundation

// 배열 처리
let names = ["Anna", "Alex", "Brain", "Jack"]

for name in names {
    print("Hello, \(name)")
}

// Dictionary
let numberOfLegs = ["Spider":8, "Ant":6, "Cat":4]
for (animalName, legCount) in numberOfLegs {
    print("\(animalName)'s have \(legCount) legs.")
}

// 범위 연산자
let seq1 = 1...5
for i in seq1 {
    print("\(i) times 5 is \(i * 5)")
}

let seq2 = (1...5).reversed()
for i in seq2 {
    print("\(i) times 5 is \(i * 5)")
}

// 증가치 간격 조절
let minutes = 60
let minutesInterval = 5
for tickMark in stride(from: 0, to: minutes, by: minutesInterval) {
    print(tickMark)
}

for tickMark in stride(from: 0, through: minutes, by: minutesInterval) {
    print(tickMark)
}
