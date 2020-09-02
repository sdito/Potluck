//
//  Visit.swift
//  restaurants
//
//  Created by Steven Dito on 8/25/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import Foundation


class Visit: Codable {
    
    var djangoRestaurantID: Int
    var restaurantName: String
    var mainImage: String
    var comment: String
    var mainImageHeight: Int
    var mainImageWidth: Int
    var accountID: Int
    var accountUsername: String
    private var serverDate: Date
    
    var userDate: String {
        let currentDate = serverDate.convertFromUTC()
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar.current
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: currentDate)
    }
    
    enum CodingKeys: String, CodingKey {
        case djangoRestaurantID = "restaurant"
        case restaurantName = "restaurant_name"
        case mainImage = "main_image"
        case comment
        case serverDate = "date"
        case mainImageHeight = "main_image_height"
        case mainImageWidth = "main_image_width"
        case accountID = "account"
        case accountUsername = "account_username"
    }
    
    
    class VisitDecoder: Decodable {
        var visits: [Visit]?
    }
    
    
    class SingleVisitDecoder: Decodable {
        var visit: Visit
    }
        
    
}
