//
//  AccessToken.swift
//  messenger
//
//  Created by Тофик Мамедов on 21.01.2025.
//

import Foundation

struct AccessToken: Codable {
    let accessToken, tokenType: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
    }
}

class AuthorizationError: Codable {
    let detail: String
}

enum AuthorizationResponse: Codable {
    case success(AccessToken)
    case failure(AuthorizationError)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let accessToken = try? container.decode(AccessToken.self) {
            self = .success(accessToken)
        } else if let errorResponse = try? container.decode(AuthorizationError.self) {
            self = .failure(errorResponse)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Неизвестный формат ответа")
        }
    }
}
