//
//  Todo.swift
//  SQLiteDid
//
//  Created by electrozone on 3/31/26.
//

import Foundation

struct Todo: Identifiable {
    var id: Int
    var content: String
    var isCompleted: Bool
    var priority: Int

    init(id: Int, content: String, isCompleted: Bool = false, priority: Int = 0) {
        self.id = id
        self.content = content
        self.isCompleted = isCompleted
        self.priority = priority
    }
}
