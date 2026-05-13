//
//  FacilityRecommendation.swift
//  hangangpark
//

import Foundation

struct FacilityRecommendation: Decodable, Identifiable, Equatable {
    let title: String
    let description: String
    let url: URL

    var id: String { url.absoluteString }

    var displayDescription: String {
        let normalized = description
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\t", with: " ")
            .split(separator: " ")
            .joined(separator: " ")
            .trimmed

        guard !normalized.isEmpty else {
            return "상세 정보를 확인해보세요."
        }

        if normalized.count > 70 {
            return String(normalized.prefix(70)) + "..."
        }

        return normalized
    }
}
