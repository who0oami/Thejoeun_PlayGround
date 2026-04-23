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
    
    private var nextIndex: Int {
        currentIndex == imageList.count - 1 ? 0 : currentIndex + 1
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("\(imageList[currentIndex]).png")
                .font(.title)
                .bold()
            
            Spacer()
            
            Image(imageList[currentIndex])
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .overlay(alignment: .topTrailing) {
                    Image(imageList[nextIndex])
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.red, lineWidth: 5)
                        )
                }
            
            HStack(spacing: 40) {
                Button("이전") {
                    showPreviousImage()
                }

                Button("다음") {
                    showNextImage()
                }
            }
            .font(.title3)
        }
        .padding()
    }
    
    private func showPreviousImage() {
        currentIndex = currentIndex == 0 ? imageList.count - 1 : currentIndex - 1
    }
    
    private func showNextImage() {
        currentIndex = currentIndex == imageList.count - 1 ? 0 : currentIndex + 1
    }
}

#Preview {
    ContentView()
}
