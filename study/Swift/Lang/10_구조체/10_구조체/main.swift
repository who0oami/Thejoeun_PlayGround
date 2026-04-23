//
//  main.swift
//  10_구조체
//
//  Created by electrozone on 3/26/26.
//

import Foundation

// 구조체 :  Class와 유사한 기능을 하는 사용자 정의 데이터 타입
// 상속이 불가능 하다는 점을 제외하곤 Class 와 동일 하다.

struct Sample{
    var sampleProperty: Int = 10 // 가변 Property_ 값을 바꿀수 있음
    let fixedSampleProperty: Int = 10 // 불변 Property
    static var typeProperty: Int = 1000
    
    func instanceMethod()
    {
        print("instanceMethod")
    }
    
    static func typeMethod()
    {
        print("typeMethod")
    }
}

// 구조체 사용
var samp: Sample = Sample() // 인스턴스 하나 가져온 거
print(samp.sampleProperty)
samp.sampleProperty = 100
print(samp.sampleProperty)

//samp.fixedSampleProperty = 100


var samp1: Sample = Sample()
print(samp1.sampleProperty)

// Type Property
Sample.typeProperty = 3000
Sample.typeMethod()

// 학생 구조체
struct Student{
    var name: String = "Unknown"
    var `class`: String = "swift"
    
    static func selfIntroduce(){
        print("학생 타입 입니다.")
    }
    
    func selfIntroduce(){
        print("저는 \(`class`)반 \(name)입니다.")
    }
}

Student.selfIntroduce()

var james: Student = Student()
james.name = "James"
james.class = "스위프트"
james.selfIntroduce()

var cathy: Student = Student()
cathy.name = "Cathy"
cathy.class = "Swift"
cathy.selfIntroduce()
