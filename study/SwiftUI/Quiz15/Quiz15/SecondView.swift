//
//  SecondView.swift
//  Navigation
//
//  Created by electrozone on 3/30/26.
//

import SwiftUI

struct SecondView: View {
    @Binding var sharedLampStatus: String
    @Binding var isGreenLamp: Bool
    @State private var isLampOff = false

    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: 20) {
                HStack {
                    Text("Off")
                        .frame(width: 60, alignment: .leading)
                    Toggle("", isOn: $isLampOff)
                        .labelsHidden()
                }

                HStack {
                    Text("Green")
                        .frame(width: 60, alignment: .leading)
                    Toggle("", isOn: $isGreenLamp)
                        .labelsHidden()
                }
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Second View")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            syncToggleStateFromLamp()
        }
        .onChange(of: isLampOff) {
            updateLampStatus()
        }
        .onChange(of: isGreenLamp) {
            updateLampStatus()
        }
    }

    private func syncToggleStateFromLamp() {
        isLampOff = sharedLampStatus == "lamp_off" ? true : false
    }

    private func updateLampStatus() {
        sharedLampStatus = isLampOff ? "lamp_off" : "lamp_on"
    }
}

#Preview {
    SecondView(sharedLampStatus: .constant("lamp_on"), isGreenLamp: .constant(false))
}
