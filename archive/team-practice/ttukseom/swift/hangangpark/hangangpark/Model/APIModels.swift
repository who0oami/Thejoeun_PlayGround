//
//  APIModels.swift
//  hangangpark
//

import Foundation

struct APIResponse<DataType: Decodable>: Decodable {
    let message: String
    let data: DataType
}

struct EmptyAPIResponse: Decodable {
    let message: String
}

struct SendCodeResponse: Decodable {
    let message: String
    let data: SendCodeData?
}

struct SendCodeData: Decodable {
    let expiresAt: String?
    let code: String?
}

struct APIErrorResponse: Decodable {
    let detail: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let message = try? container.decode(String.self, forKey: .detail) {
            detail = message
            return
        }
        detail = "서버 요청을 처리할 수 없습니다."
    }

    private enum CodingKeys: String, CodingKey {
        case detail
    }
}

struct UserLoginRequest: Encodable {
    let email: String
    let password: String
}

struct SendSignupCodeRequest: Encodable {
    let email: String
}

struct UserSignupRequest: Encodable {
    let email: String
    let password: String
    let age: Int?
    let gender: String?
    let code: String
}

enum APIError: LocalizedError {
    case invalidResponse
    case decodingFailed
    case server(String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "서버 응답을 확인할 수 없습니다."
        case .decodingFailed:
            return "서버 응답 형식이 앱과 맞지 않습니다."
        case .server(let message):
            return message.koreanServerMessage
        }
    }
}

private extension String {
    var koreanServerMessage: String {
        switch self {
        case "Email already exists.":
            return "이미 가입된 이메일입니다. 로그인해주세요."
        case "Invalid email or password.":
            return "이메일 또는 비밀번호가 올바르지 않습니다."
        case "Invalid or expired verification code.":
            return "인증 코드가 올바르지 않거나 만료되었습니다."
        case "Email is required.":
            return "이메일을 입력해주세요."
        case "Password is required.":
            return "비밀번호를 입력해주세요."
        case "Failed to send verification email.":
            return "인증 이메일 발송에 실패했습니다."
        case "SMTP authentication failed. Check your email address and app password.":
            return "이메일 발송 계정 인증에 실패했습니다. SMTP 설정을 확인해주세요."
        default:
            return self
        }
    }
}
