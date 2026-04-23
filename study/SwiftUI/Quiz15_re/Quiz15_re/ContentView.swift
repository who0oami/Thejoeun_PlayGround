//
//  ContentView.swift
//  Quiz15
//
//  Created by electrozone on 3/30/26.
//

import SwiftUI
import Combine

final class LampSettings: ObservableObject {
    @Published var sharedLampStatus = "lamp_on"
    @Published var isGreenLamp = false
}

struct ContentView: View {
    @EnvironmentObject private var lampSettings: LampSettings

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
                    NavigationLink(destination: SecondView()) {
                        Image(systemName: "lightbulb")
                    }
                }
            }
        }
        .padding()
    }

    private var displayImageName: String {
        if lampSettings.sharedLampStatus == "lamp_off" {
            return "lamp_off"
        }

        return lampSettings.isGreenLamp ? "green" : "lamp_on"
    }
}

#Preview {
    ContentView()
        .environmentObject(LampSettings())
}
