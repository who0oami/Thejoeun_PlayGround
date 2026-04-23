//
//  ContentView.swift
//  Quiz06
//
//  Created by electrozone on 3/27/26.
//

import SwiftUI

struct ContentView: View {
    let imageList = [
        "flower_01",
        "flower_02",
        "flower_03",
        "flower_04",
        "flower_05",
        "flower_06"
    ]
    @State private var currentIndex = 0

    var body: some View {
        VStack(spacing: 24) {
            Text("\(imageList[currentIndex]).png")
                .font(.title)
                .bold()

            TabView(selection: $currentIndex) {
                ForEach(Array(imageList.enumerated()), id: \.offset) { indexㅣ, imageName in
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .padding(.horizontal, 12)
                        .tag(index)
                }
            }
            .frame(maxHeight: .infinity)
            .tabViewStyle(.page(indexDisplayMode: .never))

            HStack(spacing: 10) {
                ForEach(imageList.indices, id: \.self) { index in
                    Button {
                        currentIndex = index
                    } label: {
                        Circle()
                            .fill(currentIndex == index ? Color.blue : Color.gray.opacity(0.4))
                            .frame(width: 10, height: 10)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
