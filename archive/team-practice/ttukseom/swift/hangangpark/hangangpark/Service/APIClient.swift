//
//  APIClient.swift
//  hangangpark
//

import Foundation

struct APIClient {
    static let shared = APIClient()

    // iOS Simulator에서 Mac의 FastAPI 서버를 볼 때 사용하는 주소.
    private let baseURL = URL(string: "http://localhost:8008")!

    func login(email: String, password: String) async throws -> UserSession {
        let normalizedEmail = email.trimmed.lowercased()
        let body = UserLoginRequest(email: normalizedEmail, password: password)
        var request = URLRequest(url: baseURL.appending(path: "/user/login"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(data: data, response: response)

        if let response = try? JSONDecoder().decode(APIResponse<UserSession>.self, from: data) {
            return response.data
        }

        return UserSession(userid: 0, useremail: normalizedEmail, userage: nil, usersex: nil)
    }

    func sendSignupCode(email: String) async throws -> String? {
        let body = SendSignupCodeRequest(email: email.trimmed.lowercased())
        let response: SendCodeResponse = try await post("/user/send-code", body: body)
        return response.data?.code
    }

    func signup(email: String, password: String, age: Int?, gender: String?, code: String) async throws {
        let body = UserSignupRequest(
            email: email.trimmed.lowercased(),
            password: password,
            age: age,
            gender: gender,
            code: code.trimmed
        )
        let _: EmptyAPIResponse = try await post("/user/signup", body: body)
    }

    func loadLiveParkingLots() async throws -> [ParkingLotStatus] {
        let response: APIResponse<[ParkingLotStatus]> = try await get("/parkinglot/live")
        return response.data
    }

    func loadFacilityRecommendations() async throws -> [FacilityRecommendation] {
        let response: APIResponse<[FacilityRecommendation]> = try await get("/facility/recommendations")
        return response.data
    }

    private func get<Response: Decodable>(_ path: String) async throws -> Response {
        let url = baseURL.appending(path: path)
        let (data, response) = try await URLSession.shared.data(from: url)
        return try decode(data: data, response: response)
    }

    private func post<Request: Encodable, Response: Decodable>(_ path: String, body: Request) async throws -> Response {
        var request = URLRequest(url: baseURL.appending(path: path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        return try decode(data: data, response: response)
    }

    private func decode<Response: Decodable>(data: Data, response: URLResponse) throws -> Response {
        try validate(data: data, response: response)

        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            throw APIError.decodingFailed
        }
    }

    private func validate(data: Data, response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            if let error = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                throw APIError.server(error.detail)
            }
            throw APIError.server("서버 오류가 발생했습니다. (\(httpResponse.statusCode))")
        }
    }
}

extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isBlank: Bool {
        trimmed.isEmpty
    }
}
