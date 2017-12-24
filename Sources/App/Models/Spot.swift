//
//  Spot.swift
//  App
//
//  Created by Matt Gioe on 11/8/17.
//

import Foundation
import MySQLProvider

final class Spot: Model {
    let storage = Storage()
    let name: String
    let address: String
    let city: String
    let state: String
    let zipCode: Int
    let latitude: Double
    let longitude: Double
    
    func networks() throws -> [Network] {
        let networks: Siblings<Spot, Network, Pivot<Spot, Network>> = siblings()
        return try networks.all()
    }
    
    /// Creates a new State
    init(name: String, address: String, zipCode: Int, city: String, state: String, latitude: Double, longitude: Double) {
        self.name = name
        self.address = address
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.latitude = latitude
        self.longitude = longitude
    }
    
    /// Initializes the State from the
    /// database row
    init(row: Row) throws {
        name = try row.get("name")
        address = try row.get("address")
        city = try row.get("city")
        state = try row.get("state")
        zipCode = try row.get("zipCode")
        latitude = try row.get("latitude")
        longitude = try row.get("longitude")
    }
    // Serializes the State to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        try row.set("address", address)
        try row.set("city", city)
        try row.set("state", state)
        try row.set("zipCode", zipCode)
        try row.set("latitude", latitude)
        try row.set("longitude", longitude)
        return row
    }
    
}

// MARK: Fluent Preparation
extension Spot: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Countries
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("name")
            builder.string("address")
            builder.string("city")
            builder.string("state")
            builder.int("zipCode")
            builder.double("latitude")
            builder.double("longitude")
        }
    }
    
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON
// How the model converts from / to JSON.
extension Spot: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            name: json.get("name"),
            address: json.get("address"),
            zipCode: json.get("zipCode"),
            city: json.get("city"),
            state: json.get("state"),
            latitude: json.get("latitude"),
            longitude: json.get("longitude")
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("name", name)
        try json.set("address", address)
        try json.set("city", city)
        try json.set("state", state)
        try json.set("zipCode", zipCode)
        try json.set("latitude", latitude)
        try json.set("longitude", longitude)
        return json
    }
}

// MARK: HTTP
// This allows Post models to be returned
// directly in route closures
extension Spot: ResponseRepresentable { }
