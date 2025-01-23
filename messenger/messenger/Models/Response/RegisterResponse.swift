//
//  RegisterResponse.swift
//  messenger
//
//  Created by Алексей Суровцев on 20.01.2025.
//

import Foundation

struct RegisterResponse: Codable {
    let id, username, surname, name: String?
    let patronymic, email: String?
    let isVerifiedEmail: Bool?
    let role: String?
    let isArchived: Bool?
    let lastVisit, photo: String?

    enum CodingKeys: String, CodingKey {
        case id, username, surname, name, patronymic, email
        case isVerifiedEmail = "is_verified_email"
        case role
        case isArchived = "is_archived"
        case lastVisit = "last_visit"
        case photo
    }
}

