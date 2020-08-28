//
//  Establishment.swift
//  restaurants
//
//  Created by Steven Dito on 8/27/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import Foundation
import CoreLocation

class Establishment: Codable {
    var name: String
    var isRestaurant: Bool
    var longitude: Double?
    var latitude: Double?
    var yelpID: String?
    var category: String?
    var address1: String?
    var address2: String?
    var address3: String?
    var city: String?
    var zipCode: String?
    var state: String?
    var country: String?
    var visits: [Visit]?
    
    var displayAddress: String? {
        var nonNil: [String] = []
        for str in [address1, address2, address3, city, zipCode, state, country] {
            if let str = str {
                nonNil.append(str)
            }
        }
        if nonNil.count > 0 {
            return nonNil.joined(separator: ", ")
        } else {
            return nil
        }
    }
    
    var locationInMilesFromCurrentLocation: Double? {
        guard let establishmentCoordinate = coordinate else { return nil }
        let userLocationCoordinate = CLLocationManager().getUserLocation() ?? .simulatorDefault
        let establishmentLocation = CLLocation(latitude: establishmentCoordinate.latitude, longitude: establishmentCoordinate.longitude)
        let userLocation = CLLocation(latitude: userLocationCoordinate.latitude, longitude: userLocationCoordinate.longitude)
        let distance = establishmentLocation.distance(from: userLocation)
        return distance.convertMetersToMiles()
    }
    
    var coordinate: CLLocationCoordinate2D? {
        if let lat = latitude, let long = longitude {
            let userLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
            return userLocation
        } else {
            return nil
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case isRestaurant = "is_restaurant"
        case longitude
        case latitude
        case yelpID = "yelp_id"
        case category
        case address1
        case address2
        case address3
        case city
        case zipCode = "zip_code"
        case state
        case country
    }
    
    class EstablishmentDecoder: Decodable {
        var restaurants: [Establishment]?
    }
    
}


extension Array where Element == Establishment {
    mutating func sortByName() {
        self.sort { (one, two) -> Bool in
            one.name < two.name
        }
    }
}
