//
//  Address.swift
//  SQLiteImageAddress
//
//  Created by electrozone on 3/31/26.
//

import Foundation

struct Address: Identifiable, Codable, Equatable {
    let id: Int
    var name: String
    var phone: String
    var address: String
    var relation: String
    var image: String
}

struct AddressInsertPayload: Codable {
    let name: String
    let phone: String
    let address: String
    let relation: String
    let image: String
}

struct AddressUpdatePayload: Codable {
    let id: Int
    let name: String
    let phone: String
    let address: String
    let relation: String
    let image: String?
}

struct AddressUpdateImagePayload: Codable {
    let id: Int
    let image: String
}

struct AddressListResponse: Codable {
    let result: [Address]
}

struct AddressActionResponse: Codable {
    let results: String
    let message: String?
}

struct ServerMessageResponse: Codable {
    let results: String?
    let message: String?
    let detail: String?
}

struct ImageUploadResponse: Codable {
    let results: String
    let filename: String?
    let message: String?
}
