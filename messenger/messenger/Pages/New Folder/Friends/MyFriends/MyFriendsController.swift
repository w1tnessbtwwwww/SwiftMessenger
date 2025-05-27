//
//  MyFriendsController.swift
//  messenger
//
//  Created by Тофик Мамедов on 04.02.2025.
//

import Foundation
import UIKit
import Alamofire
class MyFriendsController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    var friends: FindUsers = [
        
    ]
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomFriendsCell", for: indexPath) as! CustomFriendsCell
        cell.setupCell(username: self.friends[indexPath.row].username!, photo: self.friends[indexPath.row].photo)
        cell.deleteAction = {
            [weak self, weak tableView] in
                self?.friends.remove(at: indexPath.row)
                tableView?.deleteRows(at: [indexPath], with: .fade)
        }
        return cell
    }
    
    @IBOutlet weak var friendsTable: UITableView!
    
    func fetchFriends() {
        AF.request("\(APIService.baseUrl)/friends/my", method: .get, headers: APIService.getAuthorizationHeaders()).responseDecodable(of: FindUsers.self) { response in
            switch(response.result) {
            case .success(let friends):
                self.friends = friends
                DispatchQueue.main.async {
                    self.friendsTable.reloadData()
                }
                break
            case .failure(let error):
                print(error)
                break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.friendsTable.delegate = self
        self.friendsTable.dataSource = self
        
        let nib = UINib(nibName: "CustomFriendsCell", bundle: nil)
        self.friendsTable.register(nib, forCellReuseIdentifier: "CustomFriendsCell")
        self.friendsTable.rowHeight = 80
        fetchFriends()
        
    }
    
    
    
    
}
