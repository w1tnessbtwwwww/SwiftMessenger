//
//  RegisterRequest.swift
//  messenger
//
//  Created by Тофик Мамедов on 20.01.2025.
//

import Foundation


struct RegisterRequest: Encodable {
    let username, password, surname, name: String
    let patronymic: String
}
