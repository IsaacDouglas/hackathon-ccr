//
//  Token.swift
//  backend-swift
//
//  Created by Isaac Douglas on 14/06/20.
//

import Foundation
import PerfectCrypto

enum PAError: Swift.Error {
    case genericError(String)
}

class Token: Codable {
    var token: String
    
    init(secret: String = "secret", payload: Payload) throws {
        let jwt1 = try JWTCreator(payload: payload)
        self.token = try jwt1.sign(alg: .hs256, key: secret)
    }
    
    static func verify(secret: String = "secret", token: String) throws -> Payload {
        let _token = token.replacingOccurrences(of: "Bearer ", with: "")
        
        guard let jwt = JWTVerifier(_token) else {
            throw PAError.genericError("Erro ao inicializar o JWTVerifier")
        }
        
        try jwt.verify(algo: .hs256, key: HMACKey(secret))
        return try jwt.decode(as: Payload.self)
    }
}
