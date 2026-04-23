//
//  TodoList.swift
//  Table
//
//  Created by electrozone on 3/30/26.
//

import Foundation
struct TodoList: Identifiable{
    var id = UUID() // Unique Identifier _ db에 오토 인크리먼트랑 같은거
    var items: String
    var itemsImageFile: String
}
