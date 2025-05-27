//
//  ViewController.swift
//  messenger
//
//  Created by Тофик Мамедов on 20.01.2025.
//

import UIKit
import Alamofire
class ViewController: UIViewController {

    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    @IBAction func didTapRegisterBtn(_ sender: Any) {
        
        Router.shared.pushRegister(from: self)
        
    }
    @IBAction func didTapAuthButton(_ sender: Any) {
        if (
            passwordField.text?.isEmpty == true ||
            usernameField.text?.isEmpty == true
        ) {
            AlertManager.pushPrimitiveAlert(to: self, title: "Ошибка!", desc: "Не заполнено какое-либо поле")
            return
        }
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        let parameters: [String: String] = [
            "username": "\(usernameField.text!)",
            "password": "\(passwordField.text!)"
        ]
        
        AF.request("\(APIService.baseUrl)/auth/login", method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder.default, headers: headers).responseDecodable(of: AuthorizationResponse.self) { response in
            
            switch (response.result) {
            case .success(let authResponse):
                switch (authResponse) {
                case .success(let token):
                    Router.shared.pushTabBar(from: self)
                    AlertManager.pushPrimitiveAlert(to: self, title: "Уведомление", desc: "Вы успешно авторизовались")
                    UserDefaultsHelper.shared.saveToken(token: token.accessToken)
                    let id = JWTManager().extractSubFromJWT(token.accessToken)
                    guard let id = id else { return }
                    UserDefaultsHelper.shared.saveUserId(id: id)
                    break
                case .failure(let error):
                    AlertManager.pushPrimitiveAlert(to: self, title: "Ошибка!", desc: "\(error)")
                }
                
            case .failure(let failure):
                AlertManager.pushPrimitiveAlert(to: self, title: "Неизвестная ошибка", desc: "\(failure)")
            }
            
        }
        
    }
}

