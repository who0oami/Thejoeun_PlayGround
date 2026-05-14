//
//  FacilityRecommendationViewModel.swift
//  hangangpark
//

import Combine
import Foundation

@MainActor
final class FacilityRecommendationViewModel: ObservableObject {
    @Published var recommendations: [FacilityRecommendation] = []
    @Published var message = ""
    @Published var isLoading = false

    private let apiClient: APIClient

    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    var displayRecommendations: [FacilityRecommendation] {
        recommendations
    }

    func loadRecommendations() async {
        guard !isLoading else { return }

        isLoading = true
        message = ""

        do {
            recommendations = try await apiClient.loadFacilityRecommendations()
            if recommendations.isEmpty {
                message = "연관 추천 정보가 없습니다."
            }
            isLoading = false
        } catch {
            recommendations = Self.fallbackRecommendations
            message = "서버 연결 실패로 기본 추천 정보를 표시합니다."
            isLoading = false
        }
    }

    static let fallbackRecommendations: [FacilityRecommendation] = [
        FacilityRecommendation(
            title: "뚝섬 한강공원 눈썰매장 개장",
            description: "뚝섬한강공원의 눈썰매장과 빙어잡기, 놀이기구가 올해도 찾아온다.",
            url: URL(string: "https://korean.visitseoul.net/events/%EB%9A%9D%EC%84%AC-%ED%95%9C%EA%B0%95%EA%B3%B5%EC%9B%90-%EB%88%88%EC%8D%B0%EB%A7%A4%EC%9E%A5-%EA%B0%9C%EC%9E%A5-KR/KOP009044")!
        ),
        FacilityRecommendation(
            title: "뚝섬한강공원",
            description: "서울 한강변에 위치한 수영장, 눈썰매장, 자전거도로 등 시설의 복합 여가 공간",
            url: URL(string: "https://korean.visitseoul.net/nature/TtukseomHangngRiverpark/KOPbdyynw")!
        ),
        FacilityRecommendation(
            title: "뚝섬유원지",
            description: "뚝섬의 한강 변 일대에 조성된 시민공원으로 각종 편의시설이 구비",
            url: URL(string: "https://korean.visitseoul.net/nature/%EB%9A%9D%EC%84%AC%EC%9C%A0%EC%9B%90%EC%A7%80/KOP011395")!
        ),
        FacilityRecommendation(
            title: "아리랑 하우스",
            description: "한강 뚝섬유원지내에 위치해 수상레저기구와 다양한 음식 및 편의시설이 준비된 곳",
            url: URL(string: "https://korean.visitseoul.net/entertainment/2024-arirang/KOPp8olr5")!
        )
    ]
}
