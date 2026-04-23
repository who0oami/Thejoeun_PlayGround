//
//  ContentView.swift
//  Quiz051
//
//  Created by electrozone on 3/27/26.
//

import SwiftUI

struct ContentView: View {
    @State private var lampWidth: CGFloat = 150
    @State private var lampHeight: CGFloat = 220
    @State private var imageLamp: String = "lamp_on"
    @State private var sizetoggleStatus: Bool = false
    @State private var onofftoggleStatus: Bool = true
    @State private var buttonString: String = "전구 켜짐"

    var body: some View {
        VStack {
            Spacer()

            Image(imageLamp)
                .resizable()
                .scaledToFit()
                .frame(width: lampWidth, height: lampHeight)

            Spacer()

            HStack(spacing: 32) {
                VStack {
                    Text("전구 확대스위치")
                    Toggle("", isOn: $sizetoggleStatus)
                        .labelsHidden()
                        .onChange(of: sizetoggleStatus) { _, newValue in
                            lampWidth = newValue ? 220 : 150
                            lampHeight = newValue ? 300 : 220
                        }
                }

                VStack {
                    Text(buttonString)
                    Toggle("", isOn: $onofftoggleStatus)
                        .labelsHidden()
                        .onChange(of: onofftoggleStatus) { _, newValue in
                            imageLamp = newValue ? "lamp_on" : "lamp_off"
                            buttonString = newValue ? "전구 켜짐" : "전구 꺼짐"
                        }
                }
            }
            .padding(.bottom, 24)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
