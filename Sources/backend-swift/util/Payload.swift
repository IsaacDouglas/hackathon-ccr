//
//  Payload.swift
//  backend-swift
//
//  Created by Isaac Douglas on 14/06/20.
//

import Foundation

enum PermissionType: String, Codable {
    case admin
}

class Payload: Codable {
    var sub: Int?    //(subject) = Entidade à quem o token pertence, normalmente o ID do usuário
    var iss: String? //(issuer) = Emissor do token
    var exp: CLong   //(expiration) = Timestamp de quando o token irá expirar
    var iat: CLong   //(issued at) = Timestamp de quando o token foi criado
    var aud: String? //(audience) = Destinatário do token, representa a aplicação que irá usá-lo
    
    var name: String
    var admin: Bool
    var permissions: [PermissionType]
    
    var isAuthenticated: Bool {
        let timeInterval = Date.timeInterval
        return (self.exp - timeInterval) >= 0
    }
    
    init(sub: Int? = nil, iss: String? = nil, aud: String? = nil, name: String, admin: Bool, permissions: [PermissionType]) {
        self.sub = sub
        self.iss = iss
        self.aud = aud
        self.name = name
        self.admin = admin
        self.permissions = permissions
        
        let timeInterval = Date.timeInterval
        self.exp = timeInterval + TimeIntervalType.minutes(10).totalSeconds
        self.iat = timeInterval
    }
    
    func reload() -> Payload {
        return Payload(sub: self.sub, iss: self.iss, aud: self.aud, name: self.name, admin: self.admin, permissions: self.permissions)
    }
}
