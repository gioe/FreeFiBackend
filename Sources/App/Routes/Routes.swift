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

        get("description") { req in return req.description }
        
        post("place", "new") { (request) -> ResponseRepresentable in
            guard let name = request.data["name"]?.string,
                  let address = request.data["address"]?.string,
                  let zipCode = request.data["zipCode"]?.string,
                  let zipInt = zipCode.int,
                  let latitude = request.data["latitude"]?.string,
                  let latDouble = latitude.double,
                  let longitude = request.data["longitude"]?.string,
                  let lonDouble = longitude.double else {
                    throw Abort.badRequest
            }
            
            let place = Place(name: namme, address: address, zipCode: zipInt, latitude: latDouble, longitude: lonDouble)
            try place.save()
            
            return "Success!"
        }
        try resource("posts", PostController.self)
    }
}
