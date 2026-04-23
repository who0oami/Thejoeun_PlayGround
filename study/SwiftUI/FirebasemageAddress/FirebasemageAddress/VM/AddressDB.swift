//
//  AddressDB.swift
//  FirebasemageAddress
//
//  Created by electrozone on 3/31/26.
//

import Combine
import FirebaseFirestore
import FirebaseStorage
import Foundation
import SwiftUI

@MainActor
final class AddressDB: ObservableObject {
    @Published var addressList: [Address] = []
    @Published var errorMessage = ""
    
    private let collection = Firestore.firestore().collection("address")
    private let storage = Storage.storage()
    
    func uploadImage(_ image: UIImage, fileName: String?) async throws -> String {
        let normalizedFileName = ImageUtil.normalizedUploadFileName(fileName)
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw AddressDBError.imageEncodingFailed
        }
        
        let imageReference = storage
            .reference()
            .child("addressImages/\(UUID().uuidString)_\(normalizedFileName)")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        try await upload(data: imageData, to: imageReference, metadata: metadata)
        let downloadURL = try await fetchDownloadURL(for: imageReference)
        return downloadURL.absoluteString
    }
    
    func loadAddresses() async {
        do {
            let documents = try await fetchDocuments()
            addressList = documents.compactMap(makeAddress(from:)).sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
            errorMessage = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func insertDB(
        name: String,
        phone: String,
        address: String,
        relation: String,
        image: String
    ) async -> Bool {
        let data = makePayload(
            name: name,
            phone: phone,
            address: address,
            relation: relation,
            image: image
        )
        
        do {
            try await createDocument(data: data)
            await loadAddresses()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    func updateDB(
        original: Address,
        name: String,
        phone: String,
        address: String,
        relation: String,
        image: String
    ) async -> Bool {
        let hasChanges = original.name != name ||
            original.phone != phone ||
            original.address != address ||
            original.relation != relation ||
            original.image != image
        
        if hasChanges == false {
            errorMessage = ""
            return true
        }
        
        let data = makePayload(
            name: name,
            phone: phone,
            address: address,
            relation: relation,
            image: image
        )
        
        do {
            try await updateDocument(id: original.id, data: data)
            await loadAddresses()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    func deleteDB(id: String) async -> Bool {
        do {
            try await deleteDocument(id: id)
            addressList.removeAll { $0.id == id }
            errorMessage = ""
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    private func makePayload(
        name: String,
        phone: String,
        address: String,
        relation: String,
        image: String
    ) -> [String: Any] {
        [
            "name": name.trimmingCharacters(in: .whitespacesAndNewlines),
            "phone": phone.trimmingCharacters(in: .whitespacesAndNewlines),
            "address": address.trimmingCharacters(in: .whitespacesAndNewlines),
            "relation": relation.trimmingCharacters(in: .whitespacesAndNewlines),
            "image": ImageUtil.getImageName(image),
            "updatedAt": Timestamp(date: Date())
        ]
    }
    
    private func makeAddress(from document: QueryDocumentSnapshot) -> Address? {
        let data = document.data()
        
        guard let name = data["name"] as? String,
              let phone = data["phone"] as? String,
              let address = data["address"] as? String,
              let relation = data["relation"] as? String else {
            return nil
        }
        
        return Address(
            id: document.documentID,
            name: name,
            phone: phone,
            address: address,
            relation: relation,
            image: data["image"] as? String ?? "default"
        )
    }
    
    private func fetchDocuments() async throws -> [QueryDocumentSnapshot] {
        try await withCheckedThrowingContinuation { continuation in
            collection.getDocuments { snapshot, error in
                if let error {
                    continuation.resume(throwing: AddressDBError.firestore(error))
                    return
                }
                
                continuation.resume(returning: snapshot?.documents ?? [])
            }
        }
    }
    
    private func createDocument(data: [String: Any]) async throws {
        let document = collection.document()
        var payload = data
        payload["createdAt"] = Timestamp(date: Date())
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            document.setData(payload) { error in
                if let error {
                    continuation.resume(throwing: AddressDBError.firestore(error))
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    private func updateDocument(id: String, data: [String: Any]) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            collection.document(id).updateData(data) { error in
                if let error {
                    continuation.resume(throwing: AddressDBError.firestore(error))
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    private func deleteDocument(id: String) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            collection.document(id).delete { error in
                if let error {
                    continuation.resume(throwing: AddressDBError.firestore(error))
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    private func upload(
        data: Data,
        to reference: StorageReference,
        metadata: StorageMetadata
    ) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            reference.putData(data, metadata: metadata) { _, error in
                if let error {
                    continuation.resume(throwing: AddressDBError.storage(error))
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    private func fetchDownloadURL(for reference: StorageReference) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            reference.downloadURL { url, error in
                if let error {
                    continuation.resume(throwing: AddressDBError.storage(error))
                    return
                }
                
                guard let url else {
                    continuation.resume(throwing: AddressDBError.invalidImageURL)
                    return
                }
                
                continuation.resume(returning: url)
            }
        }
    }
}

private enum AddressDBError: LocalizedError {
    case firestore(Error)
    case storage(Error)
    case imageEncodingFailed
    case invalidImageURL
    
    var errorDescription: String? {
        switch self {
        case .firestore(let error):
            return error.localizedDescription
        case .storage(let error):
            return error.localizedDescription
        case .imageEncodingFailed:
            return "이미지 데이터를 생성할 수 없습니다."
        case .invalidImageURL:
            return "업로드한 이미지 주소를 가져오지 못했습니다."
        }
    }
}
