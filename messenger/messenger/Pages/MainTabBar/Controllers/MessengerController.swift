//
//  MessengerController.swift
//  messenger
//
//  Created by Тофик Мамедов on 23.01.2025.
//

import Foundation
import UIKit
import Alamofire
class MessengerController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatSelection", for: indexPath) as! ChatSelectionController
        let item = self.chats[indexPath.row]
        cell.setupCell(chatElement: item)
        return cell
        
    }
    
    
    var chats: Chat = []

    @IBOutlet weak var myChatsTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.myChatsTableView.delegate = self
        self.myChatsTableView.dataSource = self
        self.myChatsTableView.rowHeight = 90
        self.myChatsTableView.separatorStyle = .singleLine
        self.myChatsTableView.register(UINib(nibName: "CustomChatSelection", bundle: nil), forCellReuseIdentifier: "ChatSelection")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        AF.request(
            "\(APIService.baseUrl)/chats/my",
            method: .get,
            headers: APIService.getAuthorizationHeaders()
        ).responseDecodable(of: Chat.self) { response in
            switch response.result {
                
            case .failure(let error):
                print("Raw JSON response:", response.data.flatMap { String(data: $0, encoding: .utf8) } ?? "Empty response")
                AlertManager.pushPrimitiveAlert(to: self, title: "Ошибка", desc: "Не удалось получить список чатов.")
                
            case .success(let decodedChats):
                self.chats = decodedChats
                DispatchQueue.main.async {
                    self.myChatsTableView.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chat_id: String = self.chats[indexPath.row].id
        print(chat_id)
        Router.shared.pushChat(from: self, chat_id: chat_id)
        
    }
    @IBAction func didTapOpenSearch(_ sender: Any) {
        Router.shared.pushFriendsSearch(from: self)
    }
    
}
