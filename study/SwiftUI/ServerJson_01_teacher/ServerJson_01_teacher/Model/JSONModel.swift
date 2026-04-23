//
//  JSONModel.swift
//  ServerJson_01_teacher
//
//  Created by electrozone on 3/31/26.
//

import Foundation

struct StudentJSON: Decodable {
    let code: String
    let phone: String
    let name: String
    let dept: String
}

// 암호화 작업
extension StudentJSON: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(code)
    }
}
