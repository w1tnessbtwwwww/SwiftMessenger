//
//  ChatMessage.swift
//  messenger
//
//  Created by Тофик Мамедов on 23.01.2025.
//

import Foundation

struct Message: Codable {
    let id: String?
    let message: String?
    let file: String?
    let created_time: String?
    let user: User?
}

struct User: Codable {
    let id: String?
    let surname: String?
    let name: String?
    let patronymic: String?
    let photo: String?
    
}


