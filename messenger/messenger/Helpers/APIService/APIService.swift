//
//  APIService.swift
//  messenger
//
//  Created by Тофик Мамедов on 20.01.2025.
//

import Foundation
import Alamofire
final class APIService {
    public static let baseUrl = "https://test.bytecode.su/messanger/api"
    
    public static let shared = APIService()
    
    public static func getAuthorizationHeaders(contentType: String = "application/json") -> HTTPHeaders {
        var headers: HTTPHeaders = [
            "Content-Type": contentType,
            "Authorization": "Bearer \(UserDefaultsHelper.shared.token!)"
        ]
        return headers
        
    }
    
    public func getNewsPaper(completion: @escaping([NewsItem]?) -> Void) {
        AF.request("\(APIService.baseUrl)/news", method: .get, headers: APIService.getAuthorizationHeaders()).responseDecodable(of: News.self) { response in
            
            switch (response.result) {
            case .success(let news):
                completion(news.news)
                break
            case .failure(_):
                completion(nil)
                break
            }
            
            
            
        }
    }
}
    
