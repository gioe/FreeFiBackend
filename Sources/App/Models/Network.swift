//
//  Network.swift
//  App
//
//  Created by Matt Gioe on 11/14/17.
//

import Foundation
import MySQLProvider

final class Network: Model {
    let storage = Storage()
    let name: String
    let password: String

    init(name: String, password: String) {
        self.name = name
        self.password = password
    }
    
    /// Initializes the State from the
    /// database row
    init(row: Row) throws {
        name = try row.get("name")
        password = try row.get("password")
    }
    
    // Serializes the State to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        try row.set("password", password)
        return row
    }
}

// MARK: Fluent Preparation
extension Network: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Countries
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("name")
            builder.string("password")
        }
    }
    
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON
// How the model converts from / to JSON.
extension Network: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            name: json.get("name"),
            password: json.get("password")
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("name", name)
        try json.set("password", password)
        return json
    }
}

// MARK: HTTP
// This allows Post models to be returned
// directly in route closures
extension Network: ResponseRepresentable { }

