//
//  Place.swift
//  App
//
//  Created by Matt Gioe on 11/8/17.
//

import Foundation
import PostgreSQLProvider

final class Place: Model {
    let storage = Storage()
    let name: String
    let address: String
    let zipCode: String
    let latitude: String
    let longitude: String
    
    /// Creates a new State
    init(name: String, address: String, zipCode: String, latitude: String, longitude: String) {
        self.name = name
        self.address = address
        self.zipCode = zipCode
        self.latitude = latitude
        self.longitude = longitude
    }
    
    /// Initializes the State from the
    /// database row
    init(row: Row) throws {
        name = try row.get("name")
        address = try row.get("address")
        zipCode = try row.get("zipCode")
        latitude = try row.get("latitude")
        longitude = try row.get("longitude")
    }
    // Serializes the State to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        try row.set("address", address)
        try row.set("zipCode", zipCode)
        try row.set("latitude", latitude)
        try row.set("longitude", longitude)
        return row
    }
}

// MARK: Fluent Preparation
extension Place: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Countries
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("name")
            builder.string("address")
            builder.string("zipCode")
            builder.string("latitude")
            builder.string("longitude")
        }
    }
    
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON
// How the model converts from / to JSON.
extension Place: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            name: json.get("name"),
            address: json.get("address"),
            zipCode: json.get("zipCode"),
            latitude: json.get("latitude"),
            longitude: json.get("longitude")
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("name", name)
        try json.set("address", address)
        try json.set("zipCode", zipCode)
        try json.set("latitude", latitude)
        try json.set("longitude", longitude)
        return json
    }
}

// MARK: HTTP
// This allows Post models to be returned
// directly in route closures
extension Place: ResponseRepresentable { }
