//
//  ContentView.swift
//  Quiz15
//
//  Created by electrozone on 3/30/26.
//

import SwiftUI

struct ContentView: View {
    @State private var sharedLampStatus = "lamp_on"
    @State private var isGreenLamp = false

    var body: some View {
        NavigationStack {
            VStack {
                Image(displayImageName)
                    .resizable()
                    .frame(width: 180, height: 300)
                    .fixedSize()
                    .padding(.bottom, 10)
                    .scaledToFit()
            }
            .navigationTitle("Main Title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(
                        destination: SecondView(
                            sharedLampStatus: $sharedLampStatus,
                            isGreenLamp: $isGreenLamp
                        )
                    ) {
                        Image(systemName: "lightbulb")
                    }
                }
            }
        }
        .padding()
    }

    private var displayImageName: String {
        if sharedLampStatus == "lamp_off" {
            return "lamp_off"
        }

        return isGreenLamp ? "green" : "lamp_on"
    }
}

#Preview {
    ContentView()
}
