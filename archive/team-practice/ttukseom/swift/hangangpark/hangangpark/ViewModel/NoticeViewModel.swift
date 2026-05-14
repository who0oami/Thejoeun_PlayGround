//
//  NoticeViewModel.swift
//  hangangpark
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class NoticeViewModel: ObservableObject {
    @Published private(set) var notices: [Notice] = []
    @Published private(set) var isLoading = false
    @Published var message = ""

    private let repository: NoticeRepository

    init() {
        self.repository = NoticeRepository()
    }

    init(repository: NoticeRepository) {
        self.repository = repository
    }

    func loadNotices() async {
        isLoading = true
        message = ""

        do {
            notices = try await repository.fetchNotices()
            if notices.isEmpty {
                message = "표시할 공지사항이 없습니다."
            }
            isLoading = false
        } catch {
            notices = []
            message = error.localizedDescription
            isLoading = false
        }
    }
}
