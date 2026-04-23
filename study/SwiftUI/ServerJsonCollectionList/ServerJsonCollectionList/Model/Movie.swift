//
//  Movie.swift
//  ServerJsonCollectionList
//
//  Created by Codex.
//

import Foundation

struct Movie: Identifiable, Hashable, Decodable {
    let title: String
    let imageURL: URL?

    var id: String {
        "\(title)-\(imageURL?.absoluteString ?? "no-image")"
    }

    init(title: String, imageURL: URL?) {
        self.title = title
        self.imageURL = imageURL
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKey.self)

        let title = Self.decodeFirstString(
            for: ["title", "name", "movieTitle"],
            in: container
        ) ?? "Untitled"

        let imagePath = Self.decodeFirstString(
            for: ["image", "poster", "thumbnail", "poster_url", "url"],
            in: container
        )

        self.title = title
        self.imageURL = imagePath.flatMap(URL.init(string:))
    }

    static let sample = Movie(
        title: "Sample Movie",
        imageURL: URL(string: "https://via.placeholder.com/300x450")
    )

    private static func decodeFirstString(
        for keys: [String],
        in container: KeyedDecodingContainer<DynamicCodingKey>
    ) -> String? {
        for key in keys {
            guard let codingKey = DynamicCodingKey(stringValue: key) else {
                continue
            }

            if let value = try? container.decode(String.self, forKey: codingKey) {
                return value
            }
        }

        return nil
    }
}

private struct DynamicCodingKey: CodingKey {
    let stringValue: String
    let intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
}
