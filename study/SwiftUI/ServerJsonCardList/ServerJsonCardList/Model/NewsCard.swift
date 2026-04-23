//
//  NewsCard.swift
//  ServerJsonCardList
//
//  Created by Codex.
//

import Foundation

struct NewsCard: Identifiable, Decodable {
    let id = UUID()
    let image: URL
    let category: String
    let heading: String
    let author: String

    private enum CodingKeys: String, CodingKey {
        case image
        case category
        case heading
        case author
    }
}
