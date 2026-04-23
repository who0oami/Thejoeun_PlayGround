//
//  ImageUtil.swift
//  FirebasemageAddress
//
//  Created by electrozone on 3/31/26.
//

import Foundation

struct ImageUtil {
    static func getImageName(_ name: String) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return "default"
        }
        return trimmed
    }
    
    static func imageURL(for name: String) -> URL? {
        let imageName = getImageName(name)
        guard imageName != "default" else { return nil }
        return URL(string: imageName)
    }
    
    static func normalizedUploadFileName(_ fileName: String?) -> String {
        let trimmed = fileName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if trimmed.isEmpty {
            return "\(UUID().uuidString).jpg"
        }
        
        let lowercased = trimmed.lowercased()
        if lowercased.hasSuffix(".jpg") || lowercased.hasSuffix(".jpeg") || lowercased.hasSuffix(".png") {
            return trimmed
        }
        
        return "\(trimmed).jpg"
    }
}
