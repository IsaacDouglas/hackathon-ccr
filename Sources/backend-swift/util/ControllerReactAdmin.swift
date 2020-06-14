//
//  ControllerReactAdmin.swift
//  backend-swift
//
//  Created by Isaac Douglas on 14/06/20.
//

import Foundation
import PerfectHTTP

struct Range: Codable {
    let start: Int
    let end: Int
    
    var offset: Int { return self.start }
    var limit: Int { return  self.end - self.start }
}

enum OrderType: String, Codable {
    case ASC
    case DESC
}

struct Sort: Codable {
    let field: String
    let order: OrderType
}

class FilterId: Codable {
    var id: [Int]
    
    init(id: [Int]) {
        self.id = id
    }
}

enum ActionReactAdmin: String {
    case getList
    case getMany
    case getManyReference
    case none
}

protocol ControllerReactAdmin where Self: Codable {
    static var uri: String { get }
    
    static func create()
    
    static func getList(request: HTTPRequest, response: HTTPResponse, sort: Sort, range: Range, filter: [String: Any]) -> ([Self], Int)
    static func getOne(request: HTTPRequest, response: HTTPResponse, id: Int) -> Self?
    static func getMany(request: HTTPRequest, response: HTTPResponse, filter: FilterId) -> [Self]
    static func getManyReference(request: HTTPRequest, response: HTTPResponse, sort: Sort, range: Range, filter: [String: Any]) -> [Self]
    
    static func create(request: HTTPRequest, response: HTTPResponse, record: Self) -> (Self?, Error?)
    
    static func update(request: HTTPRequest, response: HTTPResponse, record: Self) -> (Self?, Error?)
    static func updateMany(request: HTTPRequest, response: HTTPResponse, filter: FilterId, records: [Self]) -> ([Int]?, Error?)
    
    static func delete(request: HTTPRequest, response: HTTPResponse, id: Int) -> (Self?, Error?)
    static func deleteMany(request: HTTPRequest, response: HTTPResponse, filter: FilterId) -> ([Int]?, Error?)
}


extension ControllerReactAdmin {
    static var uri: String {
        return "/\(String(describing: self).lowercased())"
    }
    
    static func getManyReference(request: HTTPRequest, response: HTTPResponse, sort: Sort, range: Range, filter: [String : Any]) -> [Self] {
        return []
    }
    
    static func getList(request: HTTPRequest, response: HTTPResponse, sort: Sort, range: Range, filter: [String: Any]) -> ([Self], Int) {
        do {
            let db = try getDB(reset: false)
            let count = try db.table(Self.self).count()
            let select = try db.sql("""
                SELECT * FROM \(Self.CRUDTableName)
                ORDER BY \(sort.field) \(sort.order.rawValue)
                LIMIT \(range.limit) OFFSET \(range.offset)
                """, Self.self)
            return (select, count)
        } catch {
            Log(error.localizedDescription)
        }
        return ([], 0)
    }
    
    static func routesReactAdmin() -> [Route] {
        var routes = [Route]()
        
        routes.append(Route(method: .get, uri: "\(self.uri)/{id}", handler: { request, response in
            
            guard
                let payload = request.payload,
                payload.isAuthenticated
                else {
                    response.completed(status: .unauthorized)
                    return
            }
            
            guard
                let id = request.getId(),
                let retorno = self.getOne(request: request, response: response, id: id)
                else {
                    response.completed(status: .internalServerError)
                    return
            }
            
            do {
                let token = try Token(payload: payload.reload()).token
                
                try response
                    .setBody(json: RetornoObject<Self>(message: "ok", token: token, object: retorno))
                    .setHeader(.contentType, value: "application/json")
                    .completed()
            } catch {
                Log(error.localizedDescription)
                response.completed(status: .internalServerError)
            }
        }))
        
        
        routes.append(Route(method: .get, uri: self.uri, handler: { request, response in
            
            guard
                let payload = request.payload,
                payload.isAuthenticated
                else {
                    response.completed(status: .unauthorized)
                    return
            }
            
            guard
                let action = request.param(name: "action"),
                let actionReactAdmin = ActionReactAdmin(rawValue: action)
                else {
                    response.completed(status: .internalServerError)
                    return
            }
            
            switch actionReactAdmin {
            case .getList:
                guard
                    let sort = request.param(name: "sort")?.decoder(Sort.self),
                    let range = request.param(name: "range")?.decoder(Range.self),
                    let filter = request.param(name: "filter")?.convertToDictionary()
                    else {
                        response.completed(status: .internalServerError)
                        return
                }
                
                let (retorno, total) = self.getList(request: request, response: response, sort: sort, range: range, filter: filter)
                
                do {
                    let token = try Token(payload: payload.reload()).token
                    
                    try response
                        .setBody(json: RetornoObject<[Self]>(message: "ok", token: token, object: retorno))
                        .addHeader(.custom(name: "Access-Control-Expose-Headers"), value: "Content-Range")
                        .setHeader(.contentRange, value: "\(total)")
                        .setHeader(.contentType, value: "application/json")
                        .completed()
                } catch {
                    Log(error.localizedDescription)
                    response.completed(status: .internalServerError)
                }
                break
            case .getMany:
                guard let filter = request.param(name: "filter")?.decoder(FilterId.self)
                    else {
                        response.completed(status: .internalServerError)
                        return
                }
                
                let retorno = self.getMany(request: request, response: response, filter: filter)
                
                do {
                    let token = try Token(payload: payload.reload()).token
                    
                    try response
                        .setBody(json: RetornoObject<[Self]>(message: "ok", token: token, object: retorno))
                        .addHeader(.custom(name: "Access-Control-Expose-Headers"), value: "Content-Range")
                        .setHeader(.contentRange, value: "\(retorno.count)")
                        .setHeader(.contentType, value: "application/json")
                        .completed()
                } catch {
                    Log(error.localizedDescription)
                    response.completed(status: .internalServerError)
                }
                break
            case .getManyReference:
                response.completed(status: .notImplemented)
                break
            case .none:
                response.completed(status: .internalServerError)
                break
            }
        }))
        
        
        routes.append(Route(method: .post, uri: self.uri, handler: { request, response in
            
            guard
                let payload = request.payload,
                payload.isAuthenticated
                else {
                    response.completed(status: .unauthorized)
                    return
            }
            
            guard let record = request.postObject(Self.self) else {
                response.completed(status: .internalServerError)
                return
            }
            
            let (object, error) = self.create(request: request, response: response, record: record)
            
            do {
                if let object = object {
                    let token = try Token(payload: payload.reload()).token
                    
                    try response
                        .setBody(json: RetornoObject<Self>(message: error?.localizedDescription ?? "ok", token: token, object: object))
                        .setHeader(.contentType, value: "application/json")
                        .completed(status: .ok)
                } else {
                    response.completed(status: .internalServerError)
                }
            } catch {
                Log(error.localizedDescription)
                response.completed(status: .internalServerError)
            }
        }))
        
        routes.append(Route(method: .put, uri: "\(self.uri)/{id}", handler: { request, response in
            
            guard
                let payload = request.payload,
                payload.isAuthenticated
                else {
                    response.completed(status: .unauthorized)
                    return
            }
            
            guard let record = request.postObject(Self.self) else {
                response.completed(status: .internalServerError)
                return
            }
            
            let (object, error) = self.update(request: request, response: response, record: record)
            
            do {
                if let object = object {
                    let token = try Token(payload: payload.reload()).token
                    
                    try response
                        .setBody(json: RetornoObject<Self>(message: error?.localizedDescription ?? "ok", token: token, object: object))
                        .setHeader(.contentType, value: "application/json")
                        .completed(status: .created)
                } else {
                    response.completed(status: .internalServerError)
                }
            } catch {
                Log(error.localizedDescription)
                response.completed(status: .internalServerError)
            }
        }))
        
        routes.append(Route(method: .put, uri: self.uri, handler: { request, response in
            
            guard
                let payload = request.payload,
                payload.isAuthenticated
                else {
                    response.completed(status: .unauthorized)
                    return
            }
            
            guard
                let filter = request.param(name: "filter")?.decoder(FilterId.self),
                let records = request.postObject([Self].self)
                else {
                    response.completed(status: .internalServerError)
                    return
            }
            
            let (ids, error) = self.updateMany(request: request, response: response, filter: filter, records: records)
            
            do {
                if let ids = ids {
                    let token = try Token(payload: payload.reload()).token
                    
                    try response
                        .setBody(json: RetornoObject<[Int]>(message: error?.localizedDescription ?? "ok", token: token, object: ids))
                        .setHeader(.contentType, value: "application/json")
                        .completed(status: .created)
                } else {
                    response.completed(status: .internalServerError)
                }
            } catch {
                Log(error.localizedDescription)
                response.completed(status: .internalServerError)
            }
        }))
        
        routes.append(Route(method: .delete, uri: "\(self.uri)/{id}", handler: { request, response in
            
            guard
                let payload = request.payload,
                payload.isAuthenticated
                else {
                    response.completed(status: .unauthorized)
                    return
            }
            
            guard let id = request.getId() else {
                response.completed(status: .internalServerError)
                return
            }
            
            let (object, error) = self.delete(request: request, response: response, id: id)
            
            do {
                if let object = object {
                    let token = try Token(payload: payload.reload()).token
                    
                    try response
                        .setBody(json: RetornoObject<Self>(message: error?.localizedDescription ?? "ok", token: token, object: object))
                        .setHeader(.contentType, value: "application/json")
                        .completed(status: .ok)
                } else {
                    response.completed(status: .internalServerError)
                }
            } catch {
                Log(error.localizedDescription)
                response.completed(status: .internalServerError)
            }
        }))
        
        routes.append(Route(method: .delete, uri: self.uri, handler: { request, response in
            
            guard
                let payload = request.payload,
                payload.isAuthenticated
                else {
                    response.completed(status: .unauthorized)
                    return
            }
            
            guard
                let filter = request.param(name: "filter")?.decoder(FilterId.self)
                else {
                    response.completed(status: .internalServerError)
                    return
            }
            
            let (ids, error) = self.deleteMany(request: request, response: response, filter: filter)
            
            do {
                if let ids = ids {
                    let token = try Token(payload: payload.reload()).token
                    
                    try response
                        .setBody(json: RetornoObject<[Int]>(message: error?.localizedDescription ?? "ok", token: token, object: ids))
                        .setHeader(.contentType, value: "application/json")
                        .completed(status: .created)
                } else {
                    response.completed(status: .internalServerError)
                }
            } catch {
                Log(error.localizedDescription)
                response.completed(status: .internalServerError)
            }
        }))
        
        return routes
    }
    
}
