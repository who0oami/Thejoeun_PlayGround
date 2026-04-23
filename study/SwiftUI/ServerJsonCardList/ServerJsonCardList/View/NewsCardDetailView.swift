//
//  NewsCardDetailView.swift
//  ServerJsonCardList
//
//  Created by Codex.
//

import SwiftUI
import SDWebImageSwiftUI

struct NewsCardDetailView: View {
    let card: NewsCard

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                WebImage(url: card.image)
                    .resizable()
                    .indicator(.activity)
                    .transition(.fade(duration: 0.25))
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 280)
                    .background(Color.white.opacity(0.08))
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 24))

                VStack(alignment: .leading, spacing: 12) {
                    Text(card.category)
                        .font(.headline)
                        .foregroundStyle(Color.white.opacity(0.6))

                    Text(card.heading)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(card.author)
                        .font(.title3)
                        .foregroundStyle(Color.white.opacity(0.72))
                        .padding(.top, 4)
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 24))
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
