//
//  ContentView.swift
//  simpleTodolist
//
//  Created by electrozone on 3/30/26.
//

import SwiftUI

struct ContentView: View {
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

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
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(animals) { animal in
                        NavigationLink {
                            AnimalDetailView(animal: animal)
                        } label: {
                            AnimalCard(animal: animal)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .navigationTitle("Main View")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct AnimalCard: View {
    let animal: Animal

    var body: some View {
        VStack(spacing: 8) {
            Image(animal.imageName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 16))

            Text(animal.name)
                .font(.subheadline.weight(.semibold))
                .multilineTextAlignment(.center)
        }
        .padding(8)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ContentView()
}
