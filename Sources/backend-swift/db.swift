//
//  db.swift
//  backend-swift
//
//  Created by Isaac Douglas on 14/06/20.
//

import Foundation
import PerfectSQLite
import PerfectCRUD

let dbPath = File.pathDefault(lastPath: "db/database/ccr.db")!

typealias DBConfiguration = SQLiteDatabaseConfiguration
func getDB(reset: Bool = true) throws -> Database<DBConfiguration> {
    if reset {
        unlink(dbPath.absoluteString)
    }
    Log(dbPath.path)
    return Database(configuration: try DBConfiguration(dbPath.path))
}

func resetDB() {
    do {
        _ = try getDB(reset: true)
    } catch {
        Log(error.localizedDescription)
    }
}
