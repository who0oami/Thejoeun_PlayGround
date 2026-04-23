//
//  ContentView.swift
//  ServerJsonCollectionList
//
//  Created by electrozone on 3/31/26.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = MovieListViewModel()

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.movies.isEmpty {
                    ProgressView()
                } else if let errorMessage = viewModel.errorMessage, viewModel.movies.isEmpty {
                    ContentUnavailableView {
                        Label("목록을 불러오지 못했습니다", systemImage: "wifi.exclamationmark")
                    } description: {
                        Text(errorMessage)
                    } actions: {
                        Button("다시 시도") {
                            Task {
                                await viewModel.fetchMovies()
                            }
                        }
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(viewModel.movies) { movie in
                                NavigationLink {
                                    MovieDetailView(movie: movie)
                                } label: {
                                    MovieGridItemView(movie: movie)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                    }
                    .refreshable {
                        await viewModel.fetchMovies()
                    }
                }
            }
            .navigationTitle("Movies")
        }
        .task {
            await viewModel.fetchMovies()
        }
    }
}

#Preview {
    ContentView()
}
