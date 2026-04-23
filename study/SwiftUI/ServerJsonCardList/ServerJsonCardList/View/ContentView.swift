//
//  ContentView.swift
//  ServerJsonCardList
//
//  Created by electrozone on 3/31/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var viewModel: NewsCardListViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    Text("News")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 12)

                    if viewModel.isLoading && viewModel.cards.isEmpty {
                        Spacer()
                        ProgressView("뉴스를 불러오는 중...")
                            .tint(.white)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                        Spacer()
                    } else if let errorMessage = viewModel.errorMessage, viewModel.cards.isEmpty {
                        Spacer()
                        ContentUnavailableView(
                            "불러오기 실패",
                            systemImage: "wifi.exclamationmark",
                            description: Text(errorMessage)
                        )
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 20) {
                                ForEach(viewModel.cards) { card in
                                    NavigationLink {
                                        NewsCardDetailView(card: card)
                                    } label: {
                                        NewsCardRowView(card: card)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        }
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
        .task {
            await viewModel.fetchCards()
        }
    }
}
