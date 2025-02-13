//
//  CreateChat.swift
//  messenger
//
//  Created by Алексей Суровцев on 04.02.2025.
//

import Foundation


struct CreateChat: Encodable {
    let users: [String]
    let name: String
    let type: String = "personal"
}
