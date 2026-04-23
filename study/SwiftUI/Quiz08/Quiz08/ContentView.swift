//
//  ContentView.swift
//  Quiz08
//
//  Created by electrozone on 3/30/26.
//

import SwiftUI
import Combine

struct ContentView: View {
    // Assets.xcassets에 미리 넣어둔 이미지 이름들을 순서대로 저장합니다.
    // 배열 순서대로 화면에 보여지기 때문에, 원하는 재생 순서를 여기서 관리하면 됩니다.
    private let imageNames: [String] = [
        "flower_01",
        "flower_02",
        "flower_03",
        "flower_04",
        "flower_05",
        "flower_06"
    ]
    
    // 현재 몇 번째 이미지를 보여주고 있는지 저장하는 상태값입니다.
    // @State를 사용하면 값이 바뀔 때마다 화면이 자동으로 다시 그려집니다.
    @State private var currentIndex: Int = 0
    
    // 3초마다 신호를 보내는 타이머입니다.
    // .autoconnect()를 사용하면 View가 나타날 때 자동으로 타이머가 시작됩니다.
    private let timer = Timer.publish(every: 3.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 16) {
            // 화면 상단 설명 텍스트
            Text("3초마다 이미지 무한 반복")
                .font(.title2)
                .fontWeight(.bold)
            
            Spacer(minLength: 0)
            
            VStack(spacing: 12) {
                // 현재 보여지는 이미지 파일 이름을 이미지 바로 위에 표시합니다.
                // 별도의 색상을 주지 않았기 때문에 시스템의 기본 글자색이 사용됩니다.
                Text(imageNames[currentIndex])
                    .font(.headline)
                
                // Assets에 저장된 이미지를 이름으로 불러옵니다.
                // frame을 크게 잡아 화면 안에서 가능한 넓게 보이도록 하고,
                // scaledToFit()으로 이미지 비율은 유지합니다.
                Image(imageNames[currentIndex])
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            Spacer(minLength: 0)
        }
        .padding()
        // 타이머가 3초마다 값을 보낼 때마다 이 코드가 실행됩니다.
        .onReceive(timer) { _ in
            // 현재 인덱스에서 1을 더한 뒤, 배열 개수로 나머지 연산을 합니다.
            // 예를 들어 마지막 인덱스가 5이고 배열 개수가 6이면,
            // (5 + 1) % 6 = 0 이 되어 다시 첫 번째 이미지로 돌아갑니다.
            currentIndex = (currentIndex + 1) % imageNames.count
        }
    }
}

#Preview {
    ContentView()
}
