//
//  DetailView.swift
//  Collection_Lable
//
//  Created by electrozone on 3/31/26.
//

import SwiftUI

struct DetailView: View {
    
    var heroName: String
    
    var body: some View {
        VStack(content: {
            Text(heroName)
        })
        .navigationTitle("인물보기")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    DetailView(heroName: "James")
}
