//
//  Missao.swift
//  backend-swift
//
//  Created by Isaac Douglas on 14/06/20.
//

import Foundation
import PerfectCRUD
import PerfectHTTP
import PerfectSQLite

// MARK: - TipoType
enum TipoType: String, Codable {
    case DIARIAS = "Diárias"
    case EM_3_DIAS = "3 em 3 dias"
    case SEMANAIS = "Semanais"
}

// MARK: - TemaType
enum TemaType: String, Codable {
    case SAUDE = "Saúde"
}

// MARK: - StatusType
enum StatusType: String, Codable {
    case NAO_INICIADO = "Não iniciado"
    case EM_ANDAMENTO = "Em andamento"
    case FINALIZADO = "Finalizado"
}

// MARK: - Missao
final class Missao: Codable {
    let id: Int
    let name: String
    let descricao: String
    let tipo: String
    let tema: String
    let status: String
    let tempoMinutos, pontos: Int

    enum CodingKeys: String, CodingKey {
        case id, name, descricao, tipo, tema, status
        case tempoMinutos = "tempo_minutos"
        case pontos
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = (try? values.decode(Int.self, forKey: .id)) ?? 0
        self.name = try values.decode(String.self, forKey: .name)
        self.descricao = try values.decode(String.self, forKey: .descricao)
        self.tipo = try values.decode(String.self, forKey: .tipo)
        self.tema = try values.decode(String.self, forKey: .tema)
        self.status = try values.decode(String.self, forKey: .status)
        self.tempoMinutos = try values.decode(Int.self, forKey: .tempoMinutos)
        self.pontos = try values.decode(Int.self, forKey: .pontos)
    }
}


// MARK: - extension Missao
extension Missao {
    
    static func select() throws -> [Missao] {
        let db = try getDB(reset: false)
        let table = db.table(Missao.self)
        let list = try table.select().map({ $0 })
        return list
    }
    
    static func insert(item: Missao) throws {
        let db = try getDB(reset: false)
        let table = db.table(Missao.self)
        try table.insert(item, ignoreKeys: \Missao.id)
    }
}

extension Missao: ControllerReactAdmin {
    static func create() {
        do {
        let db = try getDB(reset: false)
        try db.sql("DROP TABLE IF EXISTS \(Missao.CRUDTableName)")
        try db.sql("""
            CREATE TABLE \(Missao.CRUDTableName) (
            id INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE,
            name text NOT NULL,
            descricao text NOT NULL,
            tipo text NOT NULL,
            tema text NOT NULL,
            status text NOT NULL,
            tempo_minutos integer NOT NULL,
            pontos integer NOT NULL
            )
            """)
        } catch {
            Log("\(error)")
        }
    }
    
    static func getOne(request: HTTPRequest, response: HTTPResponse, id: Int) -> Missao? {
        do {
            let db = try getDB(reset: false)
            let table = db.table(Missao.self)
            let item = try table.where(\Missao.id == id).select()
            return item.map({ $0 }).first
        } catch {
            Log("\(error)")
        }
        return nil
    }
    
    static func getMany(request: HTTPRequest, response: HTTPResponse, filter: FilterId) -> [Missao] {
        do {
            let db = try getDB(reset: false)
            let table = db.table(Missao.self)
            let select = try table.where(\Missao.id ~ filter.id).select()
            return select.map({ $0 })
        } catch {
            Log(error.localizedDescription)
        }
        return []
    }
    
    static func create(request: HTTPRequest, response: HTTPResponse, record: Missao) -> (Missao?, Error?) {
        do {
            let db = try getDB(reset: false)
            let table = db.table(Missao.self)
            
            var _item: Missao? = nil
            try db.transaction {
                try table.insert(record, ignoreKeys: \Missao.id)
                _item = try table.order(descending: \Missao.id).limit(1, skip: 0).select().map({ $0 }).first
            }
            return(_item, nil)
        } catch {
            return (nil, error)
        }
    }
    
    static func update(request: HTTPRequest, response: HTTPResponse, record: Missao) -> (Missao?, Error?) {
        do {
            let db = try getDB(reset: false)
            let table = db.table(Missao.self)
            let query = table.where(\Missao.id == record.id)
            try query.update(record)
            return(record, nil)
        } catch {
            return (nil, error)
        }
    }
    
    static func updateMany(request: HTTPRequest, response: HTTPResponse, filter: FilterId, records: [Missao]) -> ([Int]?, Error?) {
        do {
            let db = try getDB(reset: false)
            let table = db.table(Missao.self)
            
            try db.transaction {
                for _item in records {
                    let query = table.where(\Missao.id == _item.id)
                    try query.update(_item)
                }
            }
            return (records.map{ $0.id }, nil)
        } catch {
            return (nil, error)
        }
    }
    
    static func delete(request: HTTPRequest, response: HTTPResponse, id: Int) -> (Missao?, Error?) {
        do {
            let db = try getDB(reset: false)
            let table = db.table(Missao.self)
            let query = table.where(\Missao.id == id)
            let item = try query.select()
            let _item = item.map({ $0 }).first
            try query.delete()
            return (_item, nil)
        } catch {
            return (nil, error)
        }
    }
    
    static func deleteMany(request: HTTPRequest, response: HTTPResponse, filter: FilterId) -> ([Int]?, Error?) {
        do {
            let db = try getDB(reset: false)
            let table = db.table(Missao.self)
            let query = table.where(\Missao.id ~ filter.id)
            try query.delete()
            return (filter.id, nil)
        } catch {
            return (nil, error)
        }
    }
    

}
