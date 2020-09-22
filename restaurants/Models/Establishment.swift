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
    var djangoID: Int?
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
    var firstVisited: Date?
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
    
    var locationInMilesFromCurrentLocation: String? {
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
    
    init(name: String, isRestaurant: Bool) {
        self.name = name
        self.isRestaurant = isRestaurant
    }
    
    init(name: String, isRestaurant: Bool, djangoID: Int?, longitude: Double?, latitude: Double?, yelpID: String?, category: String?, address1: String?,
         address2: String?, address3: String?, city: String?, zipCode: String?, state: String?, country: String?, firstVisited: Date?, visits: [Visit]?) {
        self.name = name
        self.isRestaurant = isRestaurant
        self.djangoID = djangoID
        self.longitude = longitude
        self.latitude = latitude
        self.yelpID = yelpID
        self.category = category
        self.address1 = address1
        self.address2 = address2
        self.address3 = address3
        self.city = city
        self.zipCode = zipCode
        self.state = state
        self.country = country
        self.firstVisited = firstVisited
        self.visits = visits
    }
    
    // from raw values (name, address? and coordinate?)
    init(name: String, fullAddressString: String?, coordinate: CLLocationCoordinate2D?) {
        
        self.name = name
        self.isRestaurant = true
        self.updatePropertiesWithFullAddress(address: fullAddressString, coordinate: coordinate)
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case isRestaurant = "is_restaurant"
        case djangoID = "id"
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
        case firstVisited = "first_visited"
        case visits
    }
    
    struct EstablishmentDecoder: Decodable {
        var restaurants: [Establishment]?
    }
    
    func updatePropertiesWithFullAddress(address: String?, coordinate: CLLocationCoordinate2D?) {
        
        if let address = address {
            let (partDictionary, _) = Network.shared.extractAddress(address: address, forYelp: false)
            self.address1 = partDictionary["address1"]
            self.city = partDictionary["city"]
            self.state = partDictionary["state"]
            self.country = partDictionary["country"]
            self.zipCode = partDictionary["zip_code"]
        }
        
        self.latitude = coordinate?.latitude
        self.longitude = coordinate?.longitude
    }
    
    func updateSelfForValuesThatAreNil(newEstablishment new: Establishment) {
        if self.longitude == nil { self.longitude = new.longitude }
        if self.latitude == nil { self.latitude = new.longitude }
        if self.yelpID == nil { self.yelpID = new.yelpID }
        if self.category == nil { self.category = new.category }
        if self.address1 == nil { self.address1 = new.address1 }
        if self.address2 == nil { self.address2 = new.address2 }
        if self.address3 == nil { self.address3 = new.address3 }
        if self.city == nil { self.city = new.city }
        if self.zipCode == nil { self.zipCode = new.zipCode }
        if self.state == nil { self.state = new.state }
        if self.country == nil { self.country = new.country }
        
    }
    
}


extension Array where Element == Establishment {
    mutating func sortByName() {
        self.sort { (one, two) -> Bool in
            one.name < two.name
        }
    }
}
