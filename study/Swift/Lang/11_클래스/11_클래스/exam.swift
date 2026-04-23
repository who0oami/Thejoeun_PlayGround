//
//  exam.swift
//  11_클래스
//
//  Created by electrozone on 3/26/26.
//

class Exam{
    var name = ""
    var score: [Int] = []
    var tot=0, avg=0.0
    
    func input(name: String, score:Int...){
//        tot = 0
//        avg = 0.0
        self.name = name // 변수 이름이 같아서 쓴거, 다르면 self 안써도 된다
        self.score = score
        calc()
    }
    
    func calc(){
        for i in score{
            tot += i
        }
        avg = Double(tot)/Double(score.count)
    }
    
    func result(){
        print(name, score, tot, avg)
    }
    
}
