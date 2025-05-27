//
//  UserDefaultsHelper.swift
//  messenger
//
//  Created by Тофик Мамедов on 21.01.2025.
//

import Foundation

class UserDefaultsHelper {
    
    static let shared = UserDefaultsHelper()
    
    public func saveToken(token: String) {
        UserDefaults.standard.set(token, forKey: "access_token")
    }
    
    public func saveUserId(id: String) {
        UserDefaults.standard.set(id, forKey: "user_id")
    }
    
    public var id: String? {
        get {
            guard let id = UserDefaults.standard.string(forKey: "user_id") else {
                return nil
            }
            return UserDefaults.standard.string(forKey: "user_id")
        }
    }
    
    public var token: String? { get {
        guard let token = UserDefaults.standard.string(forKey: "access_token") else {
            return nil
        }
        
        return UserDefaults.standard.string(forKey: "access_token")!
    }}
    
}
