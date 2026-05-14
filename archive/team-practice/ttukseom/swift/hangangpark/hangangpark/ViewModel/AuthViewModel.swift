//
//  AuthViewModel.swift
//  hangangpark
//

import Combine
import SwiftUI

@MainActor
final class AuthViewModel: ObservableObject {
    enum Mode: String, CaseIterable, Identifiable {
        case login = "로그인"
        case signup = "회원가입"

        var id: String { rawValue }
    }

    enum Gender: String, CaseIterable, Identifiable {
        case male = "남"
        case female = "여"

        var id: String { rawValue }
    }

    @Published var mode: Mode = .login
    @Published var loginEmail = ""
    @Published var loginPassword = ""
    @Published var signupEmail = ""
    @Published var signupPassword = ""
    @Published var signupAge: Int?
    @Published var signupGender: Gender?
    @Published var verificationCode = ""
    @Published var message = ""
    @Published var isLoading = false

    let ageRange = Array(15...100)

    private let apiClient: APIClient

    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    var canLogin: Bool {
        !loginEmail.isBlank && !loginPassword.isBlank
    }

    var canSendCode: Bool {
        !signupEmail.isBlank
    }

    var canSignup: Bool {
        !signupEmail.isBlank && !signupPassword.isBlank && signupAge != nil && signupGender != nil && !verificationCode.isBlank
    }

    var signupAgeText: String {
        if let signupAge {
            return "\(signupAge)살"
        }
        return "나이 선택"
    }

    func login() async -> UserSession? {
        guard canLogin else { return nil }

        return await runRequest {
            try await apiClient.login(email: loginEmail, password: loginPassword)
        }
    }

    func sendSignupCode() async {
        guard canSendCode else { return }

        isLoading = true
        message = ""

        do {
            let code = try await apiClient.sendSignupCode(email: signupEmail)
            if let code {
                verificationCode = code
                message = "테스트 인증 코드: \(code)"
            } else {
                message = "인증 코드를 이메일로 보냈습니다."
            }
            isLoading = false
        } catch {
            message = error.localizedDescription
            isLoading = false
        }
    }

    func signup() async {
        guard canSignup else { return }

        await runAction(successMessage: "회원가입이 완료되었습니다. 로그인해주세요.") {
            try await apiClient.signup(
                email: signupEmail,
                password: signupPassword,
                age: signupAge,
                gender: signupGender?.rawValue,
                code: verificationCode
            )
        }

        if message == "회원가입이 완료되었습니다. 로그인해주세요." {
            mode = .login
            loginEmail = signupEmail
            loginPassword = ""
        }
    }

    private func runRequest<Result>(_ operation: () async throws -> Result) async -> Result? {
        isLoading = true
        message = ""

        do {
            let result = try await operation()
            isLoading = false
            return result
        } catch {
            message = error.localizedDescription
            isLoading = false
            return nil
        }
    }

    private func runAction(successMessage: String, operation: () async throws -> Void) async {
        isLoading = true
        message = ""

        do {
            try await operation()
            message = successMessage
            isLoading = false
        } catch {
            message = error.localizedDescription
            isLoading = false
        }
    }
}
