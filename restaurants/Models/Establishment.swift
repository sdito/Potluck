//
//  Establishment.swift
//  restaurants
//
//  Created by Steven Dito on 8/27/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import Foundation


class Establishment: Codable {
    var name: String
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
    
    enum CodingKeys: String, CodingKey {
        case name
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
