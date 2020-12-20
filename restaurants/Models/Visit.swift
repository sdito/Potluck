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
    var comment: String?
    
    var mainImage: String?
    var mainImageHeight: Int?
    var mainImageWidth: Int?
    
    var mainImageRatio: CGFloat? {
        if let imageHeight = mainImageHeight, let imageWidth = mainImageWidth {
            return CGFloat(imageWidth) / CGFloat(imageHeight)
        } else {
            return nil
        }
    }
    
    var person: Person?
    var otherImages: [VisitImage]
    var tags: [Tag]
    var rating: Double?
    var yelpID: String?
    
    private var serverDateVisited: Date
    private var serverDatePosted: Date
    
    var longitude: Double?
    var latitude: Double?
    
    var listPhotos: [String]? {
        guard let mainImage = mainImage else { return nil }
        var arr: [String] = [mainImage]
        for photo in otherImages {
            arr.append(photo.image)
        }
        return arr
    }
    
    private func getTagsAttributedString(smallerThanNormal: Bool) -> NSAttributedString {
        let font: UIFont = smallerThanNormal ? .smallBold : .mediumBold
        let mutableString = NSMutableAttributedString()
        for (i, tag) in tags.enumerated() {
            if i != 0 {
                mutableString.append(NSAttributedString(string: " "))
            }
            let attributedString = NSAttributedString(string: " \(tag.display) ", attributes: [
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.backgroundColor: Colors.main,
                NSAttributedString.Key.foregroundColor: UIColor.systemBackground,
            ])
            mutableString.append(attributedString)
        }
        return mutableString
    }
    
    func getTagAndCommentAttributedString(smallerThanNormal: Bool) -> (string: NSAttributedString, hasData: Bool) {
        let mutableString = NSMutableAttributedString()
        var hasData = self.hasTags
        
        let tagsAttributedString = self.getTagsAttributedString(smallerThanNormal: smallerThanNormal)
        mutableString.append(tagsAttributedString)
        
        if let commentText = self.comment {
            
            if hasData {
                // add an in-between for when there are both tags and a comment
                let middle = NSAttributedString(string: " · ", attributes: [
                    NSAttributedString.Key.font: UIFont.mediumBold,
                    NSAttributedString.Key.foregroundColor: UIColor.label
                ])
                mutableString.append(middle)
            }
            
            hasData = true
            mutableString.append(NSAttributedString(string: commentText))
        }
        
        return (mutableString, hasData)
    }
    
    var hasTags: Bool {
        return tags.count > 0
    }
    
    var accountColor: UIColor {
        return UIColor(hex: self.person?.hex_color) ?? Colors.random
    }
    
    var userDateVisited: String {
        return serverDateVisited.dateString()
    }
    
    var shortUserDateVisited: String {
        return serverDateVisited.dateString(style: .short)
    }
    
    var isCurrentUsersVisit: Bool {
        guard let id = Network.shared.account?.id else { return false }
        return self.person?.id == id
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
            return getStringForNumber(rating: rating)
        } else {
            return nil
        }
    }
    
    private func getStringForNumber(rating: Double, preSetColor: UIColor? = nil) -> NSAttributedString {
        let color = preSetColor ?? rating.getColorFromZeroToTen()
        let mutableString = NSMutableAttributedString()
        
        let ratingPortion = NSAttributedString(string: " \(rating)", attributes: [NSAttributedString.Key.font: UIFont.mediumBold,
                                                                                  NSAttributedString.Key.baselineOffset: 1.8,
                                                                                  NSAttributedString.Key.foregroundColor: color])
        
        let image = UIImage.starCircleImage.withConfiguration(UIImage.SymbolConfiguration(scale: .small)).withTintColor(color)
        let imageAttachment = NSTextAttachment(image: image)
        let imageString = NSAttributedString(attachment: imageAttachment)
        
        mutableString.append(imageString)
        mutableString.append(ratingPortion)
        
        return mutableString
    }
    
    func getDummyRatingString() -> NSAttributedString {
        return getStringForNumber(rating: 0.0, preSetColor: .clear)
    }
    
    
    func getEstablishment() -> Establishment {
        let establishment = Establishment(name: self.restaurantName, isRestaurant: false, djangoID: self.djangoRestaurantID, longitude: self.longitude, latitude: self.latitude, yelpID: self.yelpID, category: nil, address1: nil, address2: nil, address3: nil, city: nil, zipCode: nil, state: nil, country: nil, firstVisited: nil, visits: nil, userId: self.person?.id)
        
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
    
    func changeTagsProcess(presentingVC: UIViewController, visitTagsDelegate: VisitTagsDelegate?) {
        guard let delegate = visitTagsDelegate else { return }
        let vc = VisitTagsVC(delegate: delegate, tags: self.tags.map({$0.display}))
        presentingVC.present(vc, animated: true, completion: nil)
    }
    
    func changePhotosProcess(presentingVC: UIViewController) {
        let vc = ImageSelectorVC(standalone: true, previousPhotos: self.listPhotos, visit: self)
        presentingVC.present(vc, animated: true, completion: nil)
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
        
        case person = "account"
        case longitude = "restaurant_longitude"
        case latitude = "restaurant_latitude"
        case otherImages = "other_images"
        case rating
        case yelpID = "restaurant_yelp_id"
        
        case tags
    }
    
    
    class VisitFeedDecoder: Decodable {
        var visits: [Visit]
        var tags: [Tag]?
        var pending_request_count: Int?
    }
    
    
    class SingleVisitDecoder: Decodable {
        var visit: Visit
    }
        
    
}
