//
//  UsersSearchController.swift
//  messenger
//
//  Created by Алексей Суровцев on 04.02.2025.
//

import Foundation
import UIKit
import Alamofire
class UsersSearchController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var searchResult: FindUsers = [
        
    ]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomSearchFriends", for: indexPath) as! CustomSearchCellController
        cell.setupCell(searchResult[indexPath.row].username!, searchResult[indexPath.row].photo)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.searchResult[indexPath.row]
        let myId = UserDefaultsHelper.shared.id
        let request = CreateChat(users: ["\(myId!)", "\(user.id!)"], name: "\(user.name!)")
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
