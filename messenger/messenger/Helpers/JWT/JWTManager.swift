//
//  JWTManager.swift
//  messenger
//
//  Created by Алексей Суровцев on 23.01.2025.
//

import Foundation

final class JWTManager {

    func extractSubFromJWT(_ jwtToken: String) -> String? {
        // Разделяем токен на части
        let segments = jwtToken.components(separatedBy: ".")
        
        // Проверяем, что токен состоит из трех частей
        guard segments.count == 3 else {
            print("Invalid JWT token: Expected 3 segments, got \(segments.count)")
            return nil
        }
        
        // Берем payload (вторую часть)
        let payloadSegment = segments[1]
        
        // Декодируем Base64Url
        let paddedPayload = padBase64EncodedString(payloadSegment)
        guard let payloadData = Data(base64Encoded: paddedPayload) else {
            print("Failed to decode Base64Url payload")
            return nil
        }
        
        // Преобразуем Data в JSON
        do {
            let json = try JSONSerialization.jsonObject(with: payloadData, options: [])
            guard let payload = json as? [String: Any] else {
                print("Payload is not a dictionary")
                return nil
            }
            
            // Извлекаем значение sub
            if let sub = payload["sub"] as? String {
                return sub
            } else {
                print("Key 'sub' not found in payload")
                return nil
            }
        } catch {
            print("Failed to parse payload: \(error)")
            return nil
        }
    }

    // Вспомогательная функция для добавления padding в Base64Url
    private func padBase64EncodedString(_ base64Url: String) -> String {
        var base64 = base64Url
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        // Добавляем padding, если необходимо
        let paddingLength = base64.count % 4
        if paddingLength > 0 {
            base64 += String(repeating: "=", count: 4 - paddingLength)
        }
        
        return base64
    }
}
