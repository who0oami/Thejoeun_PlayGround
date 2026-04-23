//
//  QueryView.swift
//  ServerJsonCardList
//
//  Created by Codex.
//

import SwiftUI

struct QueryView: View {
    @EnvironmentObject private var viewModel: NewsCardListViewModel
    @State private var query = ""

    private var filteredCards: [NewsCard] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedQuery.isEmpty else {
            return viewModel.cards
        }

        return viewModel.cards.filter { card in
            card.category.localizedCaseInsensitiveContains(trimmedQuery) ||
            card.heading.localizedCaseInsensitiveContains(trimmedQuery) ||
            card.author.localizedCaseInsensitiveContains(trimmedQuery)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 20) {
                    TextField("카테고리, 제목, 작성자 검색", text: $query)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)
                        .background(Color(red: 0.11, green: 0.11, blue: 0.13))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)

                    if viewModel.isLoading && viewModel.cards.isEmpty {
                        Spacer()
                        ProgressView("뉴스를 불러오는 중...")
                            .tint(.white)
                            .foregroundStyle(.white)
                        Spacer()
                    } else if filteredCards.isEmpty {
                        Spacer()
                        ContentUnavailableView(
                            "검색 결과 없음",
                            systemImage: "magnifyingglass",
                            description: Text("다른 검색어로 다시 시도해보세요.")
                        )
                        .foregroundStyle(.white)
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 20) {
                                ForEach(filteredCards) { card in
                                    NavigationLink {
                                        NewsCardDetailView(card: card)
                                    } label: {
                                        NewsCardRowView(card: card)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 16)
                        }
                    }
                }
                .padding(.top, 16)
            }
            .navigationTitle("Query")
            .toolbarBackground(.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
        .task {
            await viewModel.fetchCards()
        }
    }
}
