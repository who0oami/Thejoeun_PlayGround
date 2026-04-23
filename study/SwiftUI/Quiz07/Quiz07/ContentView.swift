//
//  ContentView.swift
//  Quiz07
//
//  Created by electrozone on 3/30/26.
//

import SwiftUI
import Combine

struct ContentView: View {
    // 현재 시간을 저장하는 상태값
    // 타이머가 1초마다 동작할 때 이 값이 계속 갱신된다.
    @State private var currentDate = Date()
    
    // 사용자가 DatePicker에서 선택한 알람 시간
    @State private var selectDate = Calendar.current.date(bySetting: .second, value: 0, of: Date()) ?? Date()
    
    // 화면 배경색을 상태값으로 관리한다.
    // 기본값은 흰색.
    @State private var backgroundColor = Color.white
    
    // 알람이 이미 울리는 중인지 확인하는 상태값
    // 같은 시각에 알람이 여러 번 실행되는 것을 막기 위해 사용한다.
    @State private var isAlarmPlaying = false
    
    // 1초마다 현재 시간을 갱신하기 위한 타이머
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // 화면에 날짜와 시간을 보여줄 때 사용할 포맷터
    // 예: 2026-03-30 14:30:59
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // 현재 시간을 한 줄로 보여주는 영역
            Text("현재 시간 : \(dateFormatter.string(from: currentDate))")
                .font(.title3)
                .multilineTextAlignment(.center)
                .monospacedDigit()
            
            // 달력 화면 없이 날짜와 시간을 휠 형태로 선택할 수 있는 DatePicker
            VStack(spacing: 8) {
                Text("알람 시간 선택")
                    .font(.headline)
                
                DatePicker(
                    "알람 시간",
                    selection: $selectDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .environment(\.locale, Locale(identifier: "ko_KR"))
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            // 선택한 시간을 한 줄로 보여주는 영역
            Text("선택한 시간 : \(dateFormatter.string(from: selectDate))")
                .font(.title3)
                .multilineTextAlignment(.center)
                .monospacedDigit()
            
            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor)
        .multilineTextAlignment(.center)
        // 타이머가 1초마다 값을 보내면 현재 시간을 갱신하고
        // 알람 시간과 같은지 비교한다.
        .onReceive(timer) { _ in
            currentDate = Date()
            checkAlarmTime()
        }
        // DatePicker는 초 단위를 직접 선택하기 어렵기 때문에
        // 사용자가 시간을 바꿀 때마다 초를 00으로 맞춰 준다.
        .onChange(of: selectDate) { _, newValue in
            let normalizedDate = Calendar.current.date(bySetting: .second, value: 0, of: newValue) ?? newValue
            if normalizedDate != newValue {
                selectDate = normalizedDate
            }
        }
    }
    
    // 현재 시간과 선택한 시간을 초 단위까지 비교하는 함수
    private func checkAlarmTime() {
        let currentTimeText = dateFormatter.string(from: currentDate)
        let selectedTimeText = dateFormatter.string(from: selectDate)
        
        // 현재 시간과 선택한 시간이 완전히 같고,
        // 아직 알람이 실행 중이 아니라면 배경색을 변경한다.
        if currentTimeText == selectedTimeText && !isAlarmPlaying {
            ringAlarm()
        }
    }
    
    // 알람이 울릴 때 배경색을 변경하는 함수
    private func ringAlarm() {
        isAlarmPlaying = true
        
        // 빨간색 또는 파란색 중 하나를 랜덤으로 선택한다.
        backgroundColor = Bool.random() ? .red : .blue
        
        // 5초 동안 색을 유지한 뒤 다시 흰색으로 되돌린다.
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            backgroundColor = .white
            isAlarmPlaying = false
        }
    }
}

#Preview {
    ContentView()
}
