//
//  MovieListViewModel.swift
//  ServerJsonCollectionList
//
//  Created by Codex.
//

import Foundation
import Observation

@MainActor
@Observable
final class MovieListViewModel {
    var movies: [Movie] = []
    var isLoading = false
    var errorMessage: String?

    func fetchMovies() async {
        guard !isLoading else {
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            movies = try await MovieAPI.fetchMovies()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
