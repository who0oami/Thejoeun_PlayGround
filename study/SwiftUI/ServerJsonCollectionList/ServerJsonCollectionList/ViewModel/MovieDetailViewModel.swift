//
//  MovieDetailViewModel.swift
//  ServerJsonCollectionList
//
//  Created by Codex.
//

import Foundation
import Observation

@MainActor
@Observable
final class MovieDetailViewModel {
    var movie: Movie
    var isLoading = false

    init(movie: Movie) {
        self.movie = movie
    }

    func fetchMovieDetail() async {
        guard !isLoading else {
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            movie = try await MovieAPI.fetchMovieDetail()
        } catch {
            // The detail endpoint may be unavailable, so the selected movie remains visible.
        }
    }
}
