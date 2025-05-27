//
//  UsersSearchController.swift
//  messenger
//
//  Created by Тофик Мамедов on 04.02.2025.
//

import Foundation
import UIKit
import Alamofire
class UsersSearchController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var searchResult: FindUsers = [
        
    ]
    
    var selectedUsers: [String] = [
        
    ]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchResult.count
    }
    
    @IBAction func didTapCreateChat(_ sender: Any) {
        
        let myId = UserDefaultsHelper.shared.id
        
        let chatName = "Рандомчик 1"
        
        var chatType = "personal"
        
        if (self.selectedUsers.count > 1) {
            chatType = "group"
        }
        
        
        let request = CreateChat(users: self.selectedUsers + [myId!], name: chatName, type: chatType)
        AF.request("\(APIService.baseUrl)/chats/create_chat", method: .post, parameters: request, encoder: JSONParameterEncoder.default, headers: APIService.getAuthorizationHeaders()).responseDecodable(of: CreateChatResponse.self) { response in
            switch (response.result) {
                case .success(let chat):
                DispatchQueue.main.async {
                    Router.shared.pushChat(from: self, chat_id: chat.id)
                }
                break
            case .failure(let error):
                AlertManager.pushPrimitiveAlert(to: self, title: "Не удалось создать чат", desc: "\(error)")
                break
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomSearchFriends", for: indexPath) as! CustomSearchCellController
        cell.setupCell(searchResult[indexPath.row].username!, searchResult[indexPath.row].photo)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.searchResult[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath) as! CustomSearchCellController
        cell.isSelectedToChat.isOn = !cell.isSelectedToChat.isOn
        if cell.isSelectedToChat.isOn == true {
            self.selectedUsers.append(user.id!)
        } else {
            self.selectedUsers.remove(at: self.selectedUsers.firstIndex(of: user.id!)!)
        }
        print(self.selectedUsers)
    }
    
    public func fetchUsers() {
        AF.request("\(APIService.baseUrl)/friends/find?query=\(self.searchBar.text!)", method: .get, headers: APIService.getAuthorizationHeaders()).responseDecodable(of: FindUsers.self) { response in
            switch (response.result) {
                case .success(let users):
                DispatchQueue.main.async {
                    self.searchResult = users
                    self.resultsTable.reloadData()
                }
                break
            case .failure(let error):
                print(error)
                break
            }
        }
    }
    
    @IBAction func didEndEditSearchBar(_ sender: Any) {
        fetchUsers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Очищаем данные чата
        self.searchResult = []
        self.resultsTable.reloadData()
        
        self.selectedUsers = []
    }
    
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var resultsTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.resultsTable.delegate = self
        self.resultsTable.dataSource = self
        
        let nib = UINib(nibName: "CustomSearchCell", bundle: nil)
        
        self.resultsTable.register(nib, forCellReuseIdentifier: "CustomSearchFriends")
        self.resultsTable.rowHeight = 80
        fetchUsers()

    }

    
}
