//
//  QueryModel.swift
//  ServerJsonImageList
//
//  Created by electrozone on 3/31/26.
//

import SwiftUI

struct QueryModel{
    
    func loadData(url: URL) async throws -> [MovieJSON]{
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([MovieJSON].self, from: data)
    }
}
