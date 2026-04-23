//
//  AddressDB.swift
//  SQLiteImageAddress
//
//  Created by electrozone on 3/31/26.
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class AddressDB: ObservableObject {
    @Published var addressList: [Address] = []
    @Published var errorMessage = ""
    
    private let baseURL = URL(string: "http://127.0.0.1:8000")!
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func uploadImage(_ image: UIImage, fileName: String?) async throws -> String {
        let normalizedFileName = ImageUtil.normalizedUploadFileName(fileName)
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw AddressDBError.imageEncodingFailed
        }
        
        let boundary = UUID().uuidString
        let url = baseURL.appendingPathComponent("uploadImage")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = multipartBody(boundary: boundary, fileName: normalizedFileName, imageData: imageData)
        
        let (data, response) = try await session.data(for: request)
        try validateHTTPResponse(response: response, data: data)
        
        do {
            let uploadResponse = try JSONDecoder().decode(ImageUploadResponse.self, from: data)
            guard uploadResponse.results.uppercased() == "OK" else {
                throw AddressDBError.serverError(uploadResponse.message ?? uploadResponse.results)
            }
            return uploadResponse.filename ?? normalizedFileName
        } catch let error as AddressDBError {
            throw error
        } catch {
            throw AddressDBError.decodingFailed
        }
    }
    
    func loadAddresses() async {
        do {
            let response: AddressListResponse = try await request(path: "/select", method: "GET")
            addressList = response.result.sorted {
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
        let payload = AddressInsertPayload(
            name: name,
            phone: phone,
            address: address,
            relation: relation,
            image: image
        )
        
        do {
            let response = try await requestActionResponse(
                path: "/insert",
                method: "POST",
                body: payload
            )
            try validateActionResponse(response)
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
        let hasTextChanges = original.name != name ||
            original.phone != phone ||
            original.address != address ||
            original.relation != relation
        let hasImageChange = original.image != image
        
        if hasTextChanges == false, hasImageChange == false {
            errorMessage = ""
            return true
        }
        
        do {
            if hasTextChanges {
                let payload = AddressUpdatePayload(
                    id: original.id,
                    name: name,
                    phone: phone,
                    address: address,
                    relation: relation,
                    image: hasImageChange ? image : nil
                )
                
                let response = try await requestActionResponse(
                    path: "/update",
                    method: "PUT",
                    body: payload
                )
                try validateActionResponse(response)
            }
            
            if hasImageChange {
                let payload = AddressUpdateImagePayload(id: original.id, image: image)
                let response = try await requestActionResponse(
                    path: "/updateImage",
                    method: "PUT",
                    body: payload
                )
                try validateActionResponse(response)
            }
            
            await loadAddresses()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    func deleteDB(id: Int) async -> Bool {
        do {
            let response = try await requestActionResponse(
                path: "/delete/\(id)",
                method: "DELETE"
            )
            try validateActionResponse(response)
            addressList.removeAll { $0.id == id }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    private func request<T: Decodable>(
        path: String,
        method: String,
        body: Encodable? = nil
    ) async throws -> T {
        let urlRequest = try makeRequest(path: path, method: method, body: body)
        let (data, response) = try await session.data(for: urlRequest)
        try validateHTTPResponse(response: response, data: data)
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw AddressDBError.decodingFailed
        }
    }
    
    private func requestActionResponse(
        path: String,
        method: String,
        body: Encodable? = nil
    ) async throws -> AddressActionResponse {
        let urlRequest = try makeRequest(path: path, method: method, body: body)
        let (data, response) = try await session.data(for: urlRequest)
        try validateHTTPResponse(response: response, data: data)
        
        do {
            return try JSONDecoder().decode(AddressActionResponse.self, from: data)
        } catch {
            throw AddressDBError.decodingFailed
        }
    }
    
    private func makeRequest(
        path: String,
        method: String,
        body: Encodable?
    ) throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path.trimmingCharacters(in: CharacterSet(charactersIn: "/")))
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let body {
            request.httpBody = try JSONEncoder().encode(AnyEncodable(body))
        }
        
        return request
    }
    
    private func multipartBody(boundary: String, fileName: String, imageData: Data) -> Data {
        var data = Data()
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        data.append(imageData)
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        return data
    }
    
    private func validateHTTPResponse(response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AddressDBError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let message = decodeServerMessage(from: data) {
                throw AddressDBError.serverError(message)
            }
            
            if let rawText = String(data: data, encoding: .utf8), rawText.isEmpty == false {
                throw AddressDBError.serverError(rawText)
            }
            
            throw AddressDBError.serverError("HTTP \(httpResponse.statusCode)")
        }
    }
    
    private func validateActionResponse(_ response: AddressActionResponse) throws {
        guard response.results.uppercased() == "OK" else {
            throw AddressDBError.serverError(response.message ?? response.results)
        }
    }
    
    private func decodeServerMessage(from data: Data) -> String? {
        guard let response = try? JSONDecoder().decode(ServerMessageResponse.self, from: data) else {
            return nil
        }
        
        if let message = response.message, message.isEmpty == false {
            return message
        }
        
        if let detail = response.detail, detail.isEmpty == false {
            return detail
        }
        
        if let results = response.results, results.isEmpty == false, results.uppercased() != "OK" {
            return results
        }
        
        return nil
    }
}

private enum AddressDBError: LocalizedError {
    case invalidResponse
    case decodingFailed
    case serverError(String)
    case imageEncodingFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "서버 응답이 올바르지 않습니다."
        case .decodingFailed:
            return "서버 데이터 형식을 확인해주세요."
        case .serverError(let message):
            return message
        case .imageEncodingFailed:
            return "이미지 데이터를 생성할 수 없습니다."
        }
    }
}

private struct AnyEncodable: Encodable {
    private let encodeBlock: (Encoder) throws -> Void
    
    init(_ wrapped: Encodable) {
        encodeBlock = wrapped.encode(to:)
    }
    
    func encode(to encoder: Encoder) throws {
        try encodeBlock(encoder)
    }
}
