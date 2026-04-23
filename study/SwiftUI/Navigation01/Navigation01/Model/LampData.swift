//
//  LampDate.swift
//  Navigation01
//
//  Created by electrozone on 3/30/26.
//

import SwiftUI
internal import Combine

// 데이터 모델 정의
class LampData: ObservableObject {
    @Published var sharedData: String = "" // Published -> 내 프로젝트 전체에서 쓸수 있는 데이터
    @Published var sharedLampStatus: String = "lamp_on"
}
