//
//  SearchModel.swift
//  messenger
//
//  Created by Алексей Суровцев on 04.02.2025.
//

import Foundation

// MARK: - FindUser
struct FindUser: Codable {
    let id, username, surname, name: String?
    let patronymic: String?
    let photo: String?
}

typealias FindUsers = [FindUser]
