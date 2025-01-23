//
//  News.swift
//  messenger
//
//  Created by Алексей Суровцев on 21.01.2025.
//

import Foundation

struct News: Codable {
    let status: String
    let news: [NewsItem]
}

// MARK: - News
struct NewsItem: Codable {
    let id, title, description, url: String
    let author, image: String
    let category: [String]
    let published: String
}
