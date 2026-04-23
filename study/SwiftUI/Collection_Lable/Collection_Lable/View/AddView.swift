//
//  AddView.swift
//  Collection_Lable
//
//  Created by electrozone on 3/31/26.
//

import SwiftUI

struct AddView: View {
    @Binding var dataArray: [String] // 이 뒤에 데이터 주면 안된다
    @FocusState var isTextFieldFocused: Bool
    @State var newItem: String = ""
    @Environment(\.dismiss) var dismiss // 버튼 누르면 핑 돌아가는 거 ->Environment
    
    var body: some View {
        VStack(content: {
            HStack(content: {
                Text("인물")
                
                TextField("", text: $newItem)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 200)
                    .multilineTextAlignment(.leading)
                    .keyboardType(.default)
                    .focused($isTextFieldFocused)
            })
            .padding()
            
            Button("추가", action: {
                // 삼항연산자로 추가 가능 여부를 먼저 판단한다.
                let canAppend = (!newItem.isEmpty && !dataArray.contains(newItem)) ? true : false
                
                // 추가할 수 없는 값이면 아무 동작도 하지 않는다.
                if !canAppend {
                    return
                }
                
                // 정상적으로 추가된 경우에만 배열에 반영한다.
                dataArray.append(newItem)
                newItem = ""
                isTextFieldFocused = false //키보드 내려가게
                
                // 실제로 추가된 경우에만 이전 화면으로 돌아간다.
                dismiss() // 죽임(앞화면으로 가는거
            })
        })
        .navigationTitle("인물 추가")
        .navigationBarTitleDisplayMode(.inline) // 이 두개는 세트로 생각하면 된다 
    }
}

#Preview {
    AddView(dataArray: .constant([])) // 그림만 주고 값을 주진 않을 거라 비워둠
}
