//
//  JSONModel.swift
//  ServerJsonImageList
//
//  Created by electrozone on 3/31/26.
//

import SwiftUI

struct MovieJSON: Decodable{
    let image: String
    let title: String
}

// 확장
extension MovieJSON: Hashable{
    public func hash(into hasher: inout Hasher){
        hasher.combine(title)
    }
}

