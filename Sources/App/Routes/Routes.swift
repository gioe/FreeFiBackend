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
            let parameter = try request.parameters.next(String.self)

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

            guard let name = request.data["name"]?.string,
                  let address = request.data["address"]?.string,
                  let zipCode = request.data["zipCode"]?.string,
                  let latitude = request.data["latitude"]?.string,
                  let longitude = request.data["longitude"]?.string else {
                    return Response(status: .badRequest)
            }
            
            let place = Place(name: name, address: address, zipCode: zipCode, latitude: latitude, longitude: longitude)
            try place.save()

            if let networks = request.data["networks"]?.array {
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
            
            return "Success!"
        }
    }
}
