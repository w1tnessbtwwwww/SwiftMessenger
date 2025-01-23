//
//  ChatMessage.swift
//  messenger
//
//  Created by Алексей Суровцев on 23.01.2025.
//

import Foundation

struct ChatHistory: Codable {
    let id, chatName: String
    let photo: String
    var messages: [Message]

    enum CodingKeys: String, CodingKey {
        case id
        case chatName = "chat_name"
        case photo, messages
    }
}

// MARK: - Message
struct Message: Codable {
    let senderId, message, createdTime, surname, name: String?
    let patronymic: String?
    let photo: String?

    enum CodingKeys: String, CodingKey {
        case senderId = "sender_id"
        case message
        case createdTime = "created_time"
        case surname, name, patronymic, photo
    }
}
