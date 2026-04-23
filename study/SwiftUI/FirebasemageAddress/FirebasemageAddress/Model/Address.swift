//
//  Address.swift
//  FirebasemageAddress
//
//  Created by electrozone on 3/31/26.
//

import Foundation

struct Address: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var phone: String
    var address: String
    var relation: String
    var image: String
}
