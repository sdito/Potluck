//
//  Restaurant.swift
//  restaurants
//
//  Created by Steven Dito on 7/3/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import CoreLocation

struct Restaurant {
    var id: String
    var name: String
    var latitude: Double
    var longitude: Double
    var url: String
    var imageURL: String
    var price: String
    var distance: Double
    var rating: Double
    var reviewCount: Int
    
    var reviews: [Review] = []
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: latitude)!, longitude: CLLocationDegrees(exactly: longitude)!)
    }
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case latitude
        case longitude
        case url
        case imageURL = "image_url"
        case price
        case distance
        case coordinates
        case rating
        case reviewCount = "review_count"
    }
    
}

// MARK: Decodable
extension Restaurant: Decodable {
    init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)
        let coordinates = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .coordinates)
        
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        latitude = try coordinates.decode(Double.self, forKey: .latitude)
        longitude = try coordinates.decode(Double.self, forKey: .longitude)
        url = try container.decode(String.self, forKey: .url)
        imageURL = try container.decode(String.self, forKey: .imageURL)
        price = try container.decode(String.self, forKey: .price)
        distance = try container.decode(Double.self, forKey: .distance)
        rating = try container.decode(Double.self, forKey: .rating)
        reviewCount = try container.decode(Int.self, forKey: .reviewCount)
    }
}



extension Array where Element == Restaurant {
    func getNewRestaurants(old oldRestaurants: [Restaurant]) -> [Restaurant] {
        let ids = oldRestaurants.map({$0.id})
        var newRestaurants: [Restaurant] = []
        for restaurant in self {
            if !ids.contains(restaurant.id) {
                newRestaurants.append(restaurant)
            }
        }
        return newRestaurants
    }
}
