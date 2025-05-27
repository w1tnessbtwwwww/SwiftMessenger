//
//  MyRequestsController.swift
//  messenger
//
//  Created by Тофик Мамедов on 05.02.2025.
//

import Foundation
import UIKit
import Alamofire
class MyRequestsController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var requests: FindUsers = [
        
    ]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        requests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyRequestsCell", for: indexPath) as! MyRequestsCellController
        cell.setupCell(username: requests[indexPath.row].username ?? "", photo: requests[indexPath.row].photo, requests[indexPath.row].id ?? "")
        cell.removeAction = {
            [weak self, weak tableView] in
                self?.requests.remove(at: indexPath.row)
                tableView?.deleteRows(at: [indexPath], with: .fade)
        }
        return cell
    }
    
    @IBOutlet weak var requestsTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.requestsTableView.delegate = self
        self.requestsTableView.dataSource = self
        
        self.requestsTableView.register(UINib(nibName: "MyRequestsCell", bundle: nil), forCellReuseIdentifier: "MyRequestsCell")
        self.requestsTableView.rowHeight = 150
        fetchRequests()
    }
    
    
    
    func fetchRequests() {
        AF.request("\(APIService.baseUrl)/friends/requests/for_me", method: .get, headers: APIService.getAuthorizationHeaders()).responseDecodable(of: FindUsers.self) { response in
            switch response.result {
            case .success(let requests):
                self.requests = requests
                DispatchQueue.main.async {
                    self.requestsTableView.reloadData()
                }
            case .failure(let error):
                print("Error loading friends")
            }
        }
    }
    
    
}
