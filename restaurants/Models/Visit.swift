//
//  Visit.swift
//  restaurants
//
//  Created by Steven Dito on 8/25/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class Visit: Codable {
    var djangoOwnID: Int
    var djangoRestaurantID: Int
    var restaurantName: String
    var mainImage: String
    var comment: String?
    var mainImageHeight: Int
    var mainImageWidth: Int
    var accountID: Int
    var accountUsername: String
    var rating: Double
    var otherImages: [VisitImage]
    var yelpID: String?
    
    private var serverDate: Date
    private var longitude: Double?
    private var latitude: Double?
    
    var currentDate: Date {
        return serverDate.convertFromUTC()
    }
    
    var listPhotos: [String] {
        var arr: [String] = [mainImage]
        for photo in otherImages {
            arr.append(photo.image)
        }
        return arr
    }
    
    var userDate: String {
        return currentDate.dateString()
    }
    
    var shortUserDate: String {
        return currentDate.dateString(style: .short)
    }
    
    var coordinate: CLLocationCoordinate2D? {
        if let long = longitude, let lat = latitude {
            return CLLocationCoordinate2D(latitude: lat, longitude: long)
        } else {
            return nil
        }
    }
    
    var ratingString: NSAttributedString {
        let mutableString = NSMutableAttributedString()
        
        let ratingPortion = NSAttributedString(string: "\(rating) ", attributes: [NSAttributedString.Key.font: UIFont.mediumBold, NSAttributedString.Key.baselineOffset: 1.8])
        let image = UIImage.starCircleImage.withConfiguration(UIImage.SymbolConfiguration(scale: .small)).withTintColor(rating.getColorFromZeroToTen())
        let imageAttachment = NSTextAttachment(image: image)
        let imageString = NSAttributedString(attachment: imageAttachment)
        
        mutableString.append(ratingPortion)
        mutableString.append(imageString)
        
        return mutableString
    }
    
    func getEstablishment() -> Establishment {
        let establishment = Establishment(name: self.restaurantName, isRestaurant: false, djangoID: self.djangoRestaurantID, longitude: self.longitude, latitude: self.latitude, yelpID: self.yelpID, category: nil, address1: nil, address2: nil, address3: nil, city: nil, zipCode: nil, state: nil, country: nil, firstVisited: nil, visits: nil)
        return establishment
    }
    
    enum CodingKeys: String, CodingKey {
        case djangoOwnID = "id"
        case djangoRestaurantID = "restaurant"
        case restaurantName = "restaurant_name"
        case mainImage = "main_image"
        case comment
        case serverDate = "date"
        case mainImageHeight = "main_image_height"
        case mainImageWidth = "main_image_width"
        case accountID = "account"
        case accountUsername = "account_username"
        case longitude = "restaurant_longitude"
        case latitude = "restaurant_latitude"
        case otherImages = "other_images"
        case rating
        case yelpID = "restaurant_yelp_id"
    }
    
    
    class VisitDecoder: Decodable {
        var visits: [Visit]?
    }
    
    
    class SingleVisitDecoder: Decodable {
        var visit: Visit
    }
        
    
}
