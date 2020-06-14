//
//  Retorno.swift
//  backend-swift
//
//  Created by Isaac Douglas on 14/06/20.
//

import Foundation

// MARK: - RetornoTypeBase
protocol RetornoTypeBase: class, Codable {
    var message: String { get set }
    var token: String? { get set }
}

// MARK: - RetornoSimple
class RetornoSimple: RetornoTypeBase {
    var message: String
    var token: String?
    
    init(message: String, token: String? = nil) {
        self.message = message
        self.token = token
    }
    
    enum CodingKeys: String, CodingKey {
        case message
        case token
    }
    
}

// MARK: - RetornoObject
class RetornoObject<T: Codable>: RetornoTypeBase {
    var message: String
    var token: String?
    var object: T?
    
    init(message: String, token: String? = nil, object: T? = nil) {
        self.message = message
        self.token = token
        self.object = object
    }
    
    enum CodingKeys: String, CodingKey {
        case message
        case token
        case object
    }
}
