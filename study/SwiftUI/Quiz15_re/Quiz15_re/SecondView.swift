//
//  SecondView.swift
//  Navigation
//
//  Created by electrozone on 3/30/26.
//

import SwiftUI

struct SecondView: View {
    @EnvironmentObject private var lampSettings: LampSettings
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
                    Toggle("", isOn: $lampSettings.isGreenLamp)
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
        .onChange(of: lampSettings.isGreenLamp) {
            updateLampStatus()
        }
    }

    private func syncToggleStateFromLamp() {
        isLampOff = lampSettings.sharedLampStatus == "lamp_off"
    }

    private func updateLampStatus() {
        lampSettings.sharedLampStatus = isLampOff ? "lamp_off" : "lamp_on"
    }
}

#Preview {
    SecondView()
        .environmentObject(LampSettings())
}
