//
//  NewsCardListViewModel.swift
//  ServerJsonCardList
//
//  Created by Codex.
//

import Combine
import Foundation

@MainActor
final class NewsCardListViewModel: ObservableObject {
    @Published private(set) var cards: [NewsCard] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let cardsURL = URL(string: "https://zeushahn.github.io/Test/ios/cards.json")!

    func fetchCards() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        do {
            let (data, _) = try await URLSession.shared.data(from: cardsURL)
            cards = try JSONDecoder().decode([NewsCard].self, from: data)
        } catch {
            errorMessage = "뉴스를 불러오지 못했습니다."
        }

        isLoading = false
    }
}
