//
//  AlertManager.swift
//  messenger
//
//  Created by Алексей Суровцев on 20.01.2025.
//

import Foundation
import UIKit

final class AlertManager {
    
    
    private init () {}
    
    public static func pushPrimitiveAlert(to: UIViewController,
                            title: String,
                            desc: String,
                            buttonText: String = "OK") {
        
        let alert = UIAlertController(title: title, message: desc, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonText, style: .default))
        to.present(alert, animated: true)
        
    }
    
}
