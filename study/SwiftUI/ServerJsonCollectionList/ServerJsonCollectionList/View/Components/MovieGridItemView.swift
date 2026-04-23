//
//  MovieGridItemView.swift
//  ServerJsonCollectionList
//
//  Created by Codex.
//

import SwiftUI
import SDWebImageSwiftUI

struct MovieGridItemView: View {
    let movie: Movie

    var body: some View {
        WebImage(url: movie.imageURL) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            Rectangle()
                .fill(Color.gray.opacity(0.15))
                .overlay {
                    ProgressView()
                        .tint(.gray)
                }
        }
        .indicator(.activity)
        .frame(maxWidth: .infinity)
        .aspectRatio(2 / 3, contentMode: .fit)
        .background(Color.gray.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .clipped()
        .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    MovieGridItemView(movie: .sample)
        .padding()
}
