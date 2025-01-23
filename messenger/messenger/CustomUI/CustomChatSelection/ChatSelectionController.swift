//
//  ChatSelectionController.swift
//  messenger
//
//  Created by Алексей Суровцев on 23.01.2025.
//

import Foundation
import UIKit
import Kingfisher
class ChatSelectionController: UITableViewCell {

    
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var lastMessage: UILabel!
    @IBOutlet weak var dialogName: UILabel!
    @IBOutlet weak var companionAvatar: UIImageView!
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var chatId: String? = nil

    public func setupCell(chatElement: ChatElement) {
        self.companionAvatar.kf.setImage(with: URL(string: chatElement.photo))
        self.lastMessage.text = chatElement.lastMessage?.message ?? "No last message"
        self.dialogName.text = chatElement.chatName
        self.chatId = chatElement.id
        self.companionAvatar.layer.cornerRadius = companionAvatar.frame.width / 2
        self.companionAvatar.clipsToBounds = true
        let dateString = chatElement.lastMessage?.createdTime
        

        // Создаем DateFormatter для парсинга входной строки
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX") // Фиксируем локаль для корректного парсинга

        guard let dateString = dateString else {
            self.timeStamp.text = ""
            return
        }
        
        // Парсим строку в Date
        guard let date = inputFormatter.date(from: dateString) else {
            return
        }

        // Создаем DateFormatter для вывода времени
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "HH:mm" // Формат: часы (24h) и минуты

        // Получаем время в нужном формате
        let timeString = outputFormatter.string(from: date)
        self.timeStamp.text = timeString
    }
    
    
}
