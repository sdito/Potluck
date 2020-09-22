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
    var otherImages: [VisitImage]
    var rating: Double?
    var yelpID: String?
    
    private var serverDateVisited: Date // from extracting the date on the main image
    private var serverDatePosted: Date  // need to use, for auto_add in django
    
    var longitude: Double?
    var latitude: Double?
    
    var currentDateVisited: Date { // visited
        return serverDateVisited.convertFromUTC()
    }
    
    var listPhotos: [String] {
        var arr: [String] = [mainImage]
        for photo in otherImages {
            arr.append(photo.image)
        }
        return arr
    }
    
    var userDateVisited: String {
        return currentDateVisited.dateString()
    }
    
    var shortUserDateVisited: String {
        return currentDateVisited.dateString(style: .short)
    }
    
    var coordinate: CLLocationCoordinate2D? {
        if let long = longitude, let lat = latitude {
            return CLLocationCoordinate2D(latitude: lat, longitude: long)
        } else {
            return nil
        }
    }
    
    var ratingString: NSAttributedString? {
        
        if let rating = rating {
            let mutableString = NSMutableAttributedString()
            
            let ratingPortion = NSAttributedString(string: "\(rating) ", attributes: [NSAttributedString.Key.font: UIFont.mediumBold, NSAttributedString.Key.baselineOffset: 1.8])
            let image = UIImage.starCircleImage.withConfiguration(UIImage.SymbolConfiguration(scale: .small)).withTintColor(rating.getColorFromZeroToTen())
            let imageAttachment = NSTextAttachment(image: image)
            let imageString = NSAttributedString(attachment: imageAttachment)
            
            mutableString.append(ratingPortion)
            mutableString.append(imageString)
            
            return mutableString
        } else {
            return nil
        }
    }
    
    func getEstablishment() -> Establishment {
        let establishment = Establishment(name: self.restaurantName, isRestaurant: false, djangoID: self.djangoRestaurantID, longitude: self.longitude, latitude: self.latitude, yelpID: self.yelpID, category: nil, address1: nil, address2: nil, address3: nil, city: nil, zipCode: nil, state: nil, country: nil, firstVisited: nil, visits: nil)
        return establishment
    }
    
    func updateFromEstablishment(establishment: Establishment) {
        self.restaurantName = establishment.name
        self.latitude = establishment.latitude
        self.longitude = establishment.longitude
    }
    
    func changeValueProcess(presentingVC: UIViewController, mode: EnterValueView.Mode, enterTextViewDelegate: EnterValueViewDelegate?) {
        let text: String? = (mode == .rating) ? nil : "Edit comment for visit to \(self.restaurantName) on \(self.shortUserDateVisited)"
        let placeHolder: String? = (mode == .rating) ? nil : "Enter new comment"
        
        let editTextView = EnterValueView(text: text, placeholder: placeHolder, controller: nil, delegate: enterTextViewDelegate, mode: mode)
        
        let vc = ShowViewVC(newView: editTextView, mode: .middle)
        editTextView.controller = vc
        vc.modalPresentationStyle = .overFullScreen
        presentingVC.present(vc, animated: false, completion: nil)
    }
    
    enum CodingKeys: String, CodingKey {
        case djangoOwnID = "id"
        case djangoRestaurantID = "restaurant"
        case restaurantName = "restaurant_name"
        case mainImage = "main_image"
        case comment
        case serverDateVisited = "date_visited"
        case serverDatePosted = "date_posted"
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
