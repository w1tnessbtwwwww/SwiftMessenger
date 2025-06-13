//
//  CustomSearchCellController.swift
//  messenger
//
//  Created by Тофик Мамедов on 04.02.2025.
//

import Foundation
import UIKit
import Kingfisher
class CustomSearchCellController: UITableViewCell {
 
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!

    @IBOutlet weak var isSelectedToChat: UISwitch!
    
    func setupCell(_ username: String, _ photo: String?) {
        usernameLabel.text = username
        userPhoto.kf.setImage(with: URL(string: photo ?? ""))
    }
    
}
