import Vapor
import FluentProvider

extension Droplet {
    func setupRoutes() throws {
        get("hello") { req in
            var json = JSON()
            try json.set("hello", "world")
            return json
        }

        get("plaintext") { req in
            return "Hello, world!"
        }

        // response to requests to /info domain
        // with a description of the request
        get("info") { req in
            return req.description
        }
       
        get("nearbyPlaces", String.parameter) { request in
            let parameter = try request.parameters.next(Int.self)

            let allPlaces = try Place.all().filter{ $0.zipCode == parameter }
           
            var responseJSON = JSON()
            var jsonArray: [JSON] = []
            
            try allPlaces.forEach {
                var placeJSON = try $0.makeJSON()
                let networks = try $0.networks().makeJSON()
                placeJSON["networks"] = networks
                jsonArray.append(placeJSON)
            }
        
            try responseJSON.set("data", jsonArray)
            
            return responseJSON
        }
        
        post("place", "new") { (request) -> ResponseRepresentable in
            
            guard let bytes = request.body.bytes, let json = try? JSON(bytes: bytes) else {
                return try Response(status: .badRequest, json: ["message": "Error creating JSON"])
            }
            
            guard let name = json["name"]?.string, let address = json["address"]?.string, let zipCode = json["zipCode"]?.int, let latitude = json["latitude"]?.double, let longitude = json["longitude"]?.double else {
                return try Response(status: .badRequest, json: ["message": "Couldn't produce a place. One of the variables was busted"])
            }
            
            let place = Place(name: name, address: address, zipCode: zipCode, latitude: latitude, longitude: longitude)
            try place.save()

            if let networks = json["networks"]?.array {
                try networks.forEach {

                    guard let name = $0["name"]?.string, let password = $0["password"]?.string else {
                        return
                    }

                    let network = Network(name: name, password: password)
                    try network.save()

                    let networkPivot = try Pivot<Place, Network>(place, network)
                    try networkPivot.save()

                    try place.save()

                }
            }
            return try Response(status: .accepted, json: ["message": "Success"])
        }
    }
}
