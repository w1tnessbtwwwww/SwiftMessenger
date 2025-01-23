//
//  File.swift
//  messenger
//
//  Created by Алексей Суровцев on 23.01.2025.
//

import Foundation

struct ChatElement: Codable {
    let id, chatName: String
    let photo: String
    let type: String
    let lastMessage: LastMessage?

    enum CodingKeys: String, CodingKey {
        case id
        case chatName = "chat_name"
        case photo, type
        case lastMessage = "last_message"
    }
}

// MARK: - LastMessage
struct LastMessage: Codable {
    let message, createdTime: String

    enum CodingKeys: String, CodingKey {
        case message
        case createdTime = "created_time"
    }
}

typealias Chat = [ChatElement]

