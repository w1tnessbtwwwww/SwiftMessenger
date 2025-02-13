//
//  ProfileController.swift
//  messenger
//
//  Created by Алексей Суровцев on 04.02.2025.
//

import Foundation
import UIKit

class ProfileController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func didTapMyFriends(_ sender: Any) {
        Router.shared.pushMyFriends(from: self)
    }
    
    @IBAction func didTapMyRequests(_ sender: Any) {
        Router.shared.pushMyRequests(from: self)
    }
}
