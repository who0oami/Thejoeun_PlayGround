//
//  MovieDetailView.swift
//  ServerJsonCollectionList
//
//  Created by Codex.
//

import SwiftUI
import SDWebImageSwiftUI

struct MovieDetailView: View {
    @State private var viewModel: MovieDetailViewModel

    init(movie: Movie) {
        _viewModel = State(initialValue: MovieDetailViewModel(movie: movie))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                WebImage(url: viewModel.movie.imageURL) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.15))
                        .frame(maxWidth: .infinity)
                        .aspectRatio(2 / 3, contentMode: .fit)
                        .overlay {
                            ProgressView()
                        }
                }
                .indicator(.activity)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                Text(viewModel.movie.title)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.primary)

                Spacer(minLength: 0)
            }
            .padding()
        }
        .navigationTitle("Detail")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchMovieDetail()
        }
    }
}

#Preview {
    NavigationStack {
        MovieDetailView(movie: .sample)
    }
}
