//
//  ContentView.swift
//  DatePicker
//
//  Created by electrozone on 3/30/26.
//

import SwiftUI
internal import Combine

struct ContentView: View {
    
    @State var currentDate = Date()
    @State var selectData = Date()
    
    let timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
    
    var dateFormatter: DateFormatter{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd EEE HH:mm:ss" //  HH : 24시간제, hh : 12시간제
        return formatter
    }
    
    var body: some View {
        VStack {
            Text("현재시간 :\(currentDate, formatter: dateFormatter)").onReceive(timer, perform: {input in currentDate = input
            }) // formatter안하면 , 되게 많은 정보를 가지고 옴
            
            // Date()... : 현재일 부터 미래만 선택 가능
            // ...Date() : 현재일 부터 과거만 선택 가능
            // in을 없애면 날짜 제한없이 사용가능
            DatePicker("",selection: $selectData, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                .labelsHidden()
                .datePickerStyle(.wheel) // .compact, .graphical, .wheel
                .padding()
            
            Text("선택시간 : \(selectData, formatter: dateFormatter)")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
