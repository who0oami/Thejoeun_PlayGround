//
//  Notice.swift
//  hangangpark
//

import Foundation

struct Notice: Identifiable, Equatable {
    let id: String
    let title: String
    let content: String
    let createdAt: Date
    let isImportant: Bool
}
