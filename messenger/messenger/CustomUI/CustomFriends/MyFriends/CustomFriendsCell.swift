//
//  CustomFriendsCell.swift
//  messenger
//
//  Created by Алексей Суровцев on 04.02.2025.
//

import UIKit
import Kingfisher
class CustomFriendsCell: UITableViewCell {
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var friendImage: UIImageView!
    
    var deleteAction: (() -> Void)?
    
    func setupCell(username: String, photo: String?) {
        usernameLabel.text = username
        friendImage.kf.setImage(with: URL(string: photo ?? ""))
        
    }
    
    @IBAction func didTapDeleteFriend(_ sender: Any) {
        deleteAction?()
    }
    
}
