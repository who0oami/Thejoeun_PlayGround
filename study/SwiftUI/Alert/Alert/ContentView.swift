//
//  ContentView.swift
//  Alert
//
//  Created by electrozone on 3/30/26.
//

import SwiftUI

struct ContentView: View {
    enum LampState {
        case on
        case off
        case removed
    }

    enum AlertType {
        case turnOn
        case turnOff
        case remove
    }

    // 현재 램프가 켜짐 / 꺼짐 / 제거 중 어떤 상태인지 구분하는 변수
    @State private var lampState: LampState = .removed

    // 화면에 실제로 보여줄 이미지 이름을 저장하는 변수
    @State private var currentImageName: String = "lamp_"

    // Alert를 화면에 띄울지 여부를 저장하는 변수
    @State private var isShowingAlert: Bool = false

    // 지금 띄우려는 Alert가 켜기 / 끄기 / 제거 중 어떤 것인지 구분하는 변수
    @State private var currentAlertType: AlertType = .turnOn

    var body: some View {
        VStack {
            Text("Alert")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)

            Spacer()

            Image(currentImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 220, height: 300)

            Spacer()

            HStack(spacing: 20) {
                Button("켜기") {
                    currentAlertType = .turnOn
                    isShowingAlert = true
                }

                Button("끄기") {
                    currentAlertType = .turnOff
                    isShowingAlert = true
                }

                Button("제거") {
                    currentAlertType = .remove
                    isShowingAlert = true
                }
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .alert(alertTitle, isPresented: $isShowingAlert) {
            alertButtons
        } message: {
            Text(alertMessage)
        }
    }

    private var alertTitle: String {
        switch currentAlertType {
        case .turnOn, .turnOff, .remove:
            return ""
        }
    }

    private var alertMessage: String {
        switch currentAlertType {
        case .turnOn:
            return "현재 On 상태입니다."
        case .turnOff:
            return "램프를 끄겠습니까?"
        case .remove:
            return "램프를 제거 할까요?"
        }
    }

    @ViewBuilder
    private var alertButtons: some View {
        switch currentAlertType {
        case .turnOn:
            Button("확인") {
                lampState = .on
                currentImageName = "lamp_on"
            }

        case .turnOff:
            Button("아니오", role: .cancel) { }

            Button("네") {
                lampState = .off
                currentImageName = "lamp_off"
            }

        case .remove:
            Button("아니오, 끕니다") {
                lampState = .off
                currentImageName = "lamp_off"
            }

            Button("아니오, 켭니다") {
                lampState = .on
                currentImageName = "lamp_on"
            }

            Button("네, 제거합니다", role: .destructive) {
                lampState = .removed
                currentImageName = "lamp_"
            }
        }
    }
}

#Preview {
    ContentView()
}
