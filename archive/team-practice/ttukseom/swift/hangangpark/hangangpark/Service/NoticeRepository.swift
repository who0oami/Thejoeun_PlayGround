//
//  NoticeRepository.swift
//  hangangpark
//

import Foundation

#if canImport(FirebaseCore) && canImport(FirebaseFirestore)
import FirebaseCore
import FirebaseFirestore
#endif

enum NoticeRepositoryError: LocalizedError {
    case firebaseSDKMissing
    case firebaseNotConfigured

    var errorDescription: String? {
        switch self {
        case .firebaseSDKMissing:
            return "Firebase SDK를 Xcode 패키지에 추가해주세요."
        case .firebaseNotConfigured:
            return "Firebase 설정 파일을 추가해주세요."
        }
    }
}

struct NoticeRepository {
    func fetchNotices() async throws -> [Notice] {
        #if canImport(FirebaseCore) && canImport(FirebaseFirestore)
        guard FirebaseApp.app() != nil else {
            throw NoticeRepositoryError.firebaseNotConfigured
        }

        let snapshot = try await Firestore.firestore()
            .collection("notices")
            .whereField("isVisible", isEqualTo: true)
            .getDocuments()

        return snapshot.documents.compactMap { document in
            let data = document.data()

            guard
                let title = data["title"] as? String,
                let content = data["content"] as? String,
                let timestamp = data["createdAt"] as? Timestamp
            else {
                return nil
            }

            return Notice(
                id: document.documentID,
                title: title,
                content: content,
                createdAt: timestamp.dateValue(),
                isImportant: data["isImportant"] as? Bool ?? false
            )
        }
        .sorted { $0.createdAt > $1.createdAt }
        #else
        throw NoticeRepositoryError.firebaseSDKMissing
        #endif
    }
}
