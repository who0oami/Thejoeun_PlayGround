//
//  ContentView.swift
//  simpleTodolist
//
//  Created by electrozone on 3/30/26.
//

import SwiftUI

struct ContentView: View {
    private let animals: [Animal] = [
        Animal(
            imageName: "dog",
            name: "강아지",
            category: "포유류",
            canFly: false
        ),
        Animal(
            imageName: "cat",
            name: "고양이",
            category: "포유류",
            canFly: false
        ),
        Animal(
            imageName: "cow",
            name: "소",
            category: "포유류",
            canFly: false
        ),
        Animal(
            imageName: "fox",
            name: "여우",
            category: "포유류",
            canFly: false
        ),
        Animal(
            imageName: "monkey",
            name: "원숭이",
            category: "포유류",
            canFly: false
        ),
        Animal(
            imageName: "pig",
            name: "돼지",
            category: "포유류",
            canFly: false
        ),
        Animal(
            imageName: "wolf",
            name: "늑대",
            category: "포유류",
            canFly: false
        ),
        Animal(
            imageName: "bee",
            name: "벌",
            category: "곤충류",
            canFly: true
        )
    ]

    var body: some View {
        NavigationStack {
            List(animals) { animal in
                NavigationLink {
                    AnimalDetailView(animal: animal)
                } label: {
                    AnimalRow(animal: animal)
                }
            }
            .navigationTitle("동물 리스트")
        }
    }
}

struct AnimalRow: View {
    let animal: Animal

    var body: some View {
        HStack(spacing: 16) {
            Image(animal.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 6) {
                Text(animal.name)
                    .font(.headline)
                Text(animal.imageName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AnimalDetailView: View {
    let animal: Animal

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Image(animal.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 24))

                Text(animal.name)
                    .font(.largeTitle.bold())

                Text(animal.detailText)
                    .font(.body)
            }
            .padding()
        }
        .navigationTitle(animal.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ContentView()
}
