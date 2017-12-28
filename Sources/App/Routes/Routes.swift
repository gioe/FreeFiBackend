import Vapor
import FluentProvider

extension Droplet {
    
    func setupRoutes() throws {
        
        get("status") { request in
            return "Safe"
        }
        
        
        get("place", Int.parameter) { request in
            let parameter = try request.parameters.next(Int.self)
            let spotToUpdate = try Spot.all().filter{ $0.id == Identifier(parameter) }
            
            guard !spotToUpdate.isEmpty, var firstOption = spotToUpdate.first else {
                return try Response(status: .badRequest, json: ["message": "Couldn't find a spot with this spot's id."])
            }
            
            var spotJSON = try firstOption.makeJSON()
            
            return spotJSON
        }

        get("nearbyPlaces", Int.parameter) { request in
            let parameter = try request.parameters.next(Int.self)

            let allSpots = try Spot.all().filter{ $0.zipCode == parameter }
           
            var responseJSON = JSON()
            var jsonArray: [JSON] = []
            
            try allSpots.forEach {
                var spotJSON = try $0.makeJSON()
                let networks = try $0.networks().makeJSON()
                spotJSON["networks"] = networks
                jsonArray.append(spotJSON)
            }
        
            try responseJSON.set("data", jsonArray)
            
            return responseJSON
        }
        
        put("place", "update") { request in
            guard let bytes = request.body.bytes, let json = try? JSON(bytes: bytes) else {
                return try Response(status: .badRequest, json: ["message": "Error creating JSON"])
            }
            
            guard let name = json["name"]?.string, let address = json["address"]?.string, let city = json["city"]?.string, let state = json["state"]?.string, let zipCode = json["zipCode"]?.int, let latitude = json["latitude"]?.double, let longitude = json["longitude"]?.double, let id = json["id"]?.int else {
                return try Response(status: .badRequest, json: ["message": "Couldn't produce a spots. One of the variables was malformed"])
            }
            
            let place = Spot(name: name, address: address, zipCode: zipCode, city: city, state: state, latitude: latitude, longitude: longitude)

            let spotToUpdate = try Spot.all().filter{ $0.id == Identifier(id) }
           
            guard !spotToUpdate.isEmpty, var firstOption = spotToUpdate.first else {
                return try Response(status: .badRequest, json: ["message": "Couldn't find a spot with this spot's id."])
            }
            
            firstOption = place
            try firstOption.save()
            return try Response(status: .accepted, json: ["message": "Success"])
        }
        
        post("place", "new") { request in
            
            guard let bytes = request.body.bytes, let json = try? JSON(bytes: bytes) else {
                return try Response(status: .badRequest, json: ["message": "Error creating JSON"])
            }
            
            guard let name = json["name"]?.string, let address = json["address"]?.string, let city = json["city"]?.string, let state = json["state"]?.string, let zipCode = json["zipCode"]?.int, let latitude = json["latitude"]?.double, let longitude = json["longitude"]?.double else {
                return try Response(status: .badRequest, json: ["message": "Couldn't produce a spots. One of the variables was malformed"])
            }
            
            let place = Spot(name: name, address: address, zipCode: zipCode, city: city, state: state, latitude: latitude, longitude: longitude)
            
            if let conflictingSpots = try? Spot.all().filter{ $0.latitude == place.latitude && $0.longitude == place.longitude }, !conflictingSpots.isEmpty {
                return try Response(status: .badRequest, json: ["message": "This spot already exists."])

            }
            
            try place.save()

            if let networks = json["networks"]?.array {
                try networks.forEach {

                    guard let name = $0["name"]?.string, let password = $0["password"]?.string else {
                        return
                    }

                    let network = Network(name: name, password: password)
                    try network.save()

                    let networkPivot = try Pivot<Spot, Network>(place, network)
                    try networkPivot.save()

                    try place.save()

                }
            }
            return try Response(status: .accepted, json: ["message": "Success"])
        }
    }
}
