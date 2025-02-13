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
    
    public func pushFriendsSearch(from: UIViewController) {
        let vc = UIStoryboard(name: "UsersSearch", bundle: nil).instantiateViewController(withIdentifier: "UsersSearch") as! UsersSearchController
        from.navigationController?.pushViewController(vc, animated: true)
    }
    
    public func pushMyFriends(from: UIViewController) {
        let vc = UIStoryboard(name: "MyFriends", bundle: nil).instantiateViewController(withIdentifier: "MyFriends") as! MyFriendsController
        from.navigationController?.pushViewController(vc, animated: true)
    }
    
    public func pushMyRequests(from: UIViewController) {
        let vc = UIStoryboard(name: "MyRequests", bundle: nil).instantiateViewController(withIdentifier: "MyRequests") as! MyRequestsController
        from.navigationController?.pushViewController(vc, animated: true)
    }
    
}
