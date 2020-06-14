//
//  String.swift
//  backend-swift
//
//  Created by Isaac Douglas on 14/06/20.
//

import Foundation

extension String {
    func decoder<T: Decodable>(_ type: T.Type) -> T? {
        let data = Data(self.utf8)
        return try? JSONDecoder().decode(type, from: data)
    }
    
    func convertToDictionary() -> [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                Log(error.localizedDescription)
            }
        }
        return nil
    }
}
