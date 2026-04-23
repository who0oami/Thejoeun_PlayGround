//
//  NewsCardRowView.swift
//  ServerJsonCardList
//
//  Created by Codex.
//

import SwiftUI
import SDWebImageSwiftUI

struct NewsCardRowView: View {
    let card: NewsCard

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            WebImage(url: card.image)
                .resizable()
                .indicator(.activity)
                .transition(.fade(duration: 0.25))
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .background(Color(red: 0.16, green: 0.16, blue: 0.18))
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 16))

            Text(card.category)
                .font(.headline)
                .foregroundStyle(Color.white.opacity(0.6))

            Text(card.heading)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(card.author)
                .font(.subheadline)
                .foregroundStyle(Color.white.opacity(0.72))
        }
        .padding()
        .background(Color(red: 0.11, green: 0.11, blue: 0.13))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
}
