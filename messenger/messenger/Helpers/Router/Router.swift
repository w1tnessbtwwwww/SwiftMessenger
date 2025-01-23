//
//  Router.swift
//  messenger
//
//  Created by Алексей Суровцев on 20.01.2025.
//

import Foundation
import UIKit

final class Router {
    
    public static let shared = Router()
    
    private init() { }
    
    public func pushRegister(from: UIViewController) {
        let story = UIStoryboard(name: "Register", bundle: nil)
        let vc = story.instantiateViewController(withIdentifier: "Register")
        
        from.navigationController?.pushViewController(vc, animated: true)
    }
    
    public func pushTabBar(from: UIViewController) {
        
        let story = UIStoryboard(name: "MainTabBar", bundle: nil)
        let vc = story.instantiateViewController(withIdentifier: "MainTabBar")
        from.navigationController?.pushViewController(vc, animated: true)
    }
    
    public func pushChat(from: UIViewController, chat_id: String) {
        let vc = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "Chat") as! ChatController
        vc.configureChat(chat_id: chat_id)
        from.navigationController?.pushViewController(vc, animated: true)
    }
    
}
