//
//  Address.swift
//  SQLiteImageAddress
//
//  Created by electrozone on 3/31/26.
//

import SwiftUI

struct Address: Identifiable {
    var id: Int
    var name: String
    var phone: String
    var address: String
    var relation: String
    var image: UIImage // 이거 쓰려고SwiftUI 쓴 거임
    
    init(id: Int, name: String, phone: String, address: String, relation: String, image: UIImage) {
        self.id = id
        self.name = name
        self.phone = phone
        self.address = address
        self.relation = relation
        self.image = image
    }
}
