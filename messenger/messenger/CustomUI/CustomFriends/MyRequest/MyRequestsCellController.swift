//
//  MyRequestsCellController.swift
//  messenger
//
//  Created by Алексей Суровцев on 05.02.2025.
//

import Foundation
import UIKit
import Kingfisher
import Alamofire
class MyRequestsCellController: UITableViewCell {
 
    var requestId: String = ""
    
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    func setupCell(username: String, photo: String?, _ requestId: String) {
        self.usernameLabel.text = username
        self.userPhoto.kf.setImage(with: URL(string: photo ?? ""))
        self.requestId = requestId
    }
    
    var removeAction: (() -> Void)?
    
    func acceptFriend() {
        AF.request("\(APIService.baseUrl)/friends/requests/\(self.requestId)/accept", method: .post, headers: APIService.getAuthorizationHeaders()).response { response in
            
            switch (response.result) {
            case .success:
                self.removeAction?()
            case .failure(let error):
                print(error)
            }
            
        }
    }
    
    func rejectFriend(requestId: String) {
        
    }
    
    @IBAction func didTapAcceptButton(_ sender: Any) {
        acceptFriend()
    }
    @IBAction func didTapRejectButton(_ sender: Any) {
        
    }
}
