//
//  QueryModel.swift
//  ServerJson_01_teacher
//
//  Created by electrozone on 3/31/26.
//

import Foundation

struct QueryModel{
    func loadData(url: URL) async throws -> [StudentJSON]{ // 에러 걸리면 어떻게 처리할 지 알려주는 거  ->throws
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([StudentJSON].self, from: data)
        }
    }
