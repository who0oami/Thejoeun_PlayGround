//
//  ParkingStatusViewModel.swift
//  hangangpark
//

import Combine
import SwiftUI

@MainActor
final class ParkingStatusViewModel: ObservableObject {
    @Published var parkingLots: [ParkingLotStatus] = ParkingStatusViewModel.currentSiteLots
    @Published var selectedPredictionHour = 1
    @Published var message = ""
    @Published var isLoading = false

    let predictionHours = Array(1...8)

    private let apiClient: APIClient

    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    var displayParkingLots: [ParkingLotStatus] {
        let tukseomLots = parkingLots.filter { $0.parkinglotname.contains("뚝섬") }
        return Array(tukseomLots.prefix(4))
    }

    var totalAvailable: Int {
        displayParkingLots.reduce(0) { $0 + $1.available }
    }

    var predictedTotalAvailable: Int {
        displayParkingLots.reduce(0) { $0 + predictedAvailable(for: $1) }
    }

    func predictedAvailable(for lot: ParkingLotStatus) -> Int {
        // ML 모델 연결 전 임시 계산입니다. 모델 API가 생기면 이 함수만 교체하면 됩니다.
        let hourlyDecreaseRate = 0.025
        let predictedDecrease = Int((Double(lot.capacity) * hourlyDecreaseRate * Double(selectedPredictionHour)).rounded())
        return max(0, min(lot.capacity, lot.available - predictedDecrease))
    }

    func loadParkingLots() async {
        isLoading = true
        message = ""

        do {
            let loadedLots = try await apiClient.loadLiveParkingLots()
            let tukseomLots = loadedLots.filter { $0.parkinglotname.contains("뚝섬") }
            parkingLots = Array(tukseomLots.prefix(4))

            if parkingLots.isEmpty {
                parkingLots = Self.currentSiteLots
                message = "크롤링 응답이 비어 있어 최근 확인한 주차가능대수를 표시합니다."
            }
            isLoading = false
        } catch {
            parkingLots = Self.currentSiteLots
            message = "서버 연결 실패로 최근 확인한 주차가능대수를 표시합니다."
            isLoading = false
        }
    }

    static let currentSiteLots: [ParkingLotStatus] = [
        ParkingLotStatus(
            parkinglotname: "뚝섬1주차장",
            address: "서울 광진구 자양동 409",
            available: 35,
            capacity: 64,
            occupied: 29,
            occupancyRate: 29.0 / 64.0,
            statusLabel: "여유",
            latitude: 37.5276908,
            longitude: 127.0781632
        ),
        ParkingLotStatus(
            parkinglotname: "뚝섬2주차장",
            address: "서울 광진구 자양동 427-1",
            available: 226,
            capacity: 356,
            occupied: 130,
            occupancyRate: 130.0 / 356.0,
            statusLabel: "여유",
            latitude: 37.5290757,
            longitude: 127.0735242
        ),
        ParkingLotStatus(
            parkinglotname: "뚝섬3주차장",
            address: "서울 광진구 자양동 97-5",
            available: 47,
            capacity: 123,
            occupied: 76,
            occupancyRate: 76.0 / 123.0,
            statusLabel: "보통",
            latitude: 37.5306712,
            longitude: 127.0673524
        ),
        ParkingLotStatus(
            parkinglotname: "뚝섬4주차장",
            address: "서울 광진구 자양동 97-5",
            available: 46,
            capacity: 131,
            occupied: 85,
            occupancyRate: 85.0 / 131.0,
            statusLabel: "보통",
            latitude: 37.5314716,
            longitude: 127.0644017
        )
    ]
}
