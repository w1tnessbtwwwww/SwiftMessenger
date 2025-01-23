//
//  Register.swift
//  messenger
//
//  Created by Алексей Суровцев on 20.01.2025.
//

import UIKit
import Alamofire
class Register: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var surnameField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var patronymicField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap() {
        view.endEditing(true)
    }
    
    @IBAction func didTapRegisterButton(_ sender: Any) {
        
        if (
            usernameField.text?.isEmpty == true ||
            passwordField.text?.isEmpty == true ||
            surnameField.text?.isEmpty == true ||
            nameField.text?.isEmpty == true ||
            patronymicField.text?.isEmpty == true
        ) {
            AlertManager.pushPrimitiveAlert(to: self, title: "Что-то пошло не так.", desc: "Не все поля заполнены.")
        }
        
        let reg_request = RegisterRequest(username: usernameField.text!, password: passwordField.text!, surname: surnameField.text!, name: nameField.text!, patronymic: patronymicField.text!)
        
        AF.request("\(APIService.baseUrl)/auth/register", method: .post, parameters: reg_request, encoder: JSONParameterEncoder.default).responseDecodable(of: RegisterResponse.self) { response in
            
            if (response.response!.statusCode != 200) {
                AlertManager.pushPrimitiveAlert(to: self, title: "Не удалось зарегистрироваться", desc: String(data: response.data!, encoding: .utf8)!)
                print(String(data: response.data!, encoding: .utf8))
                return
            }
            
        }
        
    }
    
}
