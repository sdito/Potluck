//
//  Restaurant.swift
//  restaurants
//
//  Created by Steven Dito on 7/3/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import CoreLocation

struct Restaurant {
    
    var name: String
    var latitude: Double
    var longitude: Double
    var url: String
    var imageURL: String
    var price: String
    var distance: Double
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: latitude)!, longitude: CLLocationDegrees(exactly: longitude)!)
    }
    
    
    enum CodingKeys: String, CodingKey {
        case name
        case latitude
        case longitude
        case url
        case imageURL = "image_url"
        case price
        case distance
        case coordinates
        case response = "businesses"
    }
    
}

// MARK: Decodable
extension Restaurant: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let response = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .response)
        let coordinates = try response.nestedContainer(keyedBy: CodingKeys.self, forKey: .coordinates)
        
        name = try response.decode(String.self, forKey: .name)
        latitude = try coordinates.decode(Double.self, forKey: .latitude)
        longitude = try coordinates.decode(Double.self, forKey: .longitude)
        url = try coordinates.decode(String.self, forKey: .url)
        imageURL = try coordinates.decode(String.self, forKey: .imageURL)
        price = try coordinates.decode(String.self, forKey: .price)
        distance = try coordinates.decode(Double.self, forKey: .distance)
        
    }
}
