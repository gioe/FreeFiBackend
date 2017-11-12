import Vapor

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

        get("place", String.parameter) { request in
            let parameter = try request.parameters.next(String.self)

            let allPlaces = try Place.all().filter{ $0.zipCode == parameter }
           
            return try allPlaces.makeJSON()
        }
        
        post("place", "new") { (request) -> ResponseRepresentable in
            guard let name = request.data["name"]?.string,
                  let address = request.data["address"]?.string,
                  let zipCode = request.data["zipCode"]?.string,
                  let latitude = request.data["latitude"]?.string,
                  let longitude = request.data["longitude"]?.string else {
                    throw Abort.badRequest
            }
            
            let place = Place(name: name, address: address, zipCode: zipCode, latitude: latitude, longitude: longitude)
            try place.save()
            
            return "Success!"
        }
    }
}
