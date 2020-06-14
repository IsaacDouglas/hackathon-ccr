//
//  HTTPRequest.swift
//  backend-swift
//
//  Created by Isaac Douglas on 14/06/20.
//

import Foundation
import PerfectHTTP

extension HTTPRequest {
    func getBodyJSON<T: Decodable>(_ type: T.Type) -> T? {
        guard let body = self.postBodyString else { return nil }
        return body.decoder(type)
    }
    
    var payload: Payload? {
        guard let authorization = self.header(.authorization) else { return nil }
        return try? Token.verify(token: authorization)
    }
    
    func postObject<T: Codable>(_ type: T.Type) -> T? {
        guard
            let body = postBodyString,
            let object = body.decoder(T.self)
            else {
                return nil
        }
        return object
    }
    
    func getId() -> Int? {
        guard
            let value = urlVariables["id"],
            let id = Int(value)
            else {
                return nil
        }
        return id
    }
}
