//
//  TodoList.swift
//  SimpleTodoList
//
//  Created by electrozone on 3/30/26.
//

import Foundation

struct Animal: Identifiable {
    let id = UUID()
    let imageName: String
    let name: String
    let category: String
    let canFly: Bool
    
    var detailText: String {
        "이 동물의 이름은 \(name)이며 분류는 \(category)이며 날 수 \(canFly ? "있습니다" : "없습니다")."
    }
}
