//
//  DetailView.swift
//  simpleTodolist
//
//  Created by electrozone on 3/30/26.
//

import SwiftUI

struct AnimalDetailView: View {
    let animal: Animal

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                Image(animal.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: min(geometry.size.width * 0.7, 280))
                    .clipShape(RoundedRectangle(cornerRadius: 24))

                Text(animal.name)
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)

                Text(animal.detailText)
                    .font(.body)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: geometry.size.height)
            .frame(maxHeight: .infinity, alignment: .center)
            .padding()
        }
        .navigationTitle("Detail View")
        .navigationBarTitleDisplayMode(.inline)
    }
}
