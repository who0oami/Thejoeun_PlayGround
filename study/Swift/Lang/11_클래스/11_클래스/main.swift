//
//  main.swift
//  11_클래스
//
//  Created by electrozone on 3/26/26.
//

import Foundation

class Sample1{
    var sampleProperty: Int = 10
    let fixedSampleProperty: Int = 10
    static var typeProperty: Int = 100
    
    func instanceMethod(){
        print("Instance Method")
    }
    
    static func typeMethod(){
        print("Type Method")
    }
}

var sample1: Sample1 = Sample1()
print(sample1.sampleProperty)

// Class 와 Struct
// 클래스와 구조체는 프로그램의 코드를 조직화 하기 위해 일반적으로 사용합니다.
// 객체지향 프로그램을 위한 필수 요소 이기도 하다.

struct Resolution{
    var width = 0
    var height = 0
}

class VideoMode{
    var resolution = Resolution()
    var interlaced: Bool = false
    var frameRate = 0.0
    var name: String?
}

let someVideoMode = VideoMode()
someVideoMode.resolution.width = 1920
someVideoMode.resolution.height = 1980

// 시험 점수 총점 및 평균 출력 _ 분리하려고 만드는 거


let st1: Exam = Exam()
st1.input(name: "유비", score: 76,67,88)

// Class의 상속

// parent class
class Animal{
    var name: String
    
    init(name: String){
        self.name = name
    }
    
    func speak(){
        print("\(name)이 소리를 냅니다.")
    }
}

let animal: Animal = Animal(name: "고래")
animal.speak( )

// Sub Class
class Dog: Animal{
    override func speak() { // 저기 가져와서 바꿔서 쓰겠다는 것
        print("\(name)이 멍멍 짖습니다.")
    }
}

let dog: Dog = Dog(name: "멍게")
dog.speak( )

class Dog1: Animal{
    var bread: String
    
    init(name: String, bread: String)
    {
        self.bread = bread
        super.init(name: name) // 내 위 생성자한테 생성자를 주는 거 (?
    }
    override func speak() {
        print("\(name) \(bread)가 멍멍 짖습니다.")
    }
    
}

let dog1: Dog1 = Dog1(name: "멍게", bread: "치와와")
dog1.speak( )

// lazy Property : 클래스의 인스턴스가 생성될 때 초기화 되지 않고 실제로 사용할때 초기화 되는 프로퍼티

// 3개 만들예정

// 일반 class
class OnCreate{
    init(){
        print("OnCreate")
    }
}

var onCreate = OnCreate()
print("---------------")


class NormalTest{
    var late = OnCreate()
    init() {
        print("Normal Test")
    }
}

var normalTest = NormalTest()
print("---------------")

class LazyTest{
    var late = OnCreate()
    init() {
        print("Lazy Test")
    }
}

var lazyTest = LazyTest()
print(lazyTest.late)
