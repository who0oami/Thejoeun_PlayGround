//
//  MovieAPI.swift
//  ServerJsonCollectionList
//
//  Created by Codex.
//

import Foundation

enum MovieAPI {
    static let moviesURL = URL(string: "https://zeushahn.github.io/Test/ios/movies.json")!
    static let movieDetailURL = URL(string: "https://zeushahn.github.io/Test/ios/movie.json")!

    static func fetchMovies() async throws -> [Movie] {
        let (data, _) = try await URLSession.shared.data(from: moviesURL)
        return try decodeMovies(from: data)
    }

    static func fetchMovieDetail() async throws -> Movie {
        let (data, _) = try await URLSession.shared.data(from: movieDetailURL)
        return try decodeMovie(from: data)
    }

    private static func decodeMovies(from data: Data) throws -> [Movie] {
        let decoder = JSONDecoder()

        if let movies = try? decoder.decode([Movie].self, from: data) {
            return movies
        }

        if let response = try? decoder.decode(MovieListResponse.self, from: data) {
            return response.movies
        }

        throw MovieAPIError.invalidResponse
    }

    private static func decodeMovie(from data: Data) throws -> Movie {
        let decoder = JSONDecoder()

        if let movie = try? decoder.decode(Movie.self, from: data) {
            return movie
        }

        if let response = try? decoder.decode(MovieListResponse.self, from: data),
           let movie = response.movies.first {
            return movie
        }

        if let movies = try? decoder.decode([Movie].self, from: data),
           let movie = movies.first {
            return movie
        }

        throw MovieAPIError.invalidResponse
    }
}

private struct MovieListResponse: Decodable {
    let movies: [Movie]
}

enum MovieAPIError: LocalizedError {
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "데이터 형식을 읽을 수 없습니다."
        }
    }
}
