//
//  UserSession.swift
//  hangangpark
//

import Foundation

struct UserSession: Decodable, Equatable, Hashable, Identifiable {
    let userid: Int
    let useremail: String
    let userage: Int?
    let usersex: Int?

    var id: Int { userid }
    var email: String { useremail }

    var genderText: String {
        switch usersex {
        case 1:
            return "남성"
        case 2:
            return "여성"
        default:
            return "미입력"
        }
    }

    private enum CodingKeys: String, CodingKey {
        case userid
        case useremail
        case userage
        case usersex
    }

    init(userid: Int, useremail: String, userage: Int?, usersex: Int?) {
        self.userid = userid
        self.useremail = useremail
        self.userage = userage
        self.usersex = usersex
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userid = try container.decodeFlexibleInt(forKey: .userid) ?? 0
        useremail = try container.decode(String.self, forKey: .useremail)
        userage = try container.decodeFlexibleIntIfPresent(forKey: .userage)
        usersex = try container.decodeFlexibleIntIfPresent(forKey: .usersex)
    }
}

private extension KeyedDecodingContainer {
    func decodeFlexibleInt(forKey key: Key) throws -> Int? {
        if let value = try? decode(Int.self, forKey: key) {
            return value
        }
        if let value = try? decode(String.self, forKey: key) {
            return Int(value)
        }
        return nil
    }

    func decodeFlexibleIntIfPresent(forKey key: Key) throws -> Int? {
        if try decodeNil(forKey: key) {
            return nil
        }
        return try decodeFlexibleInt(forKey: key)
    }
}
