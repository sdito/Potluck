//
//  Restaurant.swift
//  restaurants
//
//  Created by Steven Dito on 7/3/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import CoreLocation

class Restaurant: Decodable {
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
    var categories: [String]
    var transactions: [String]
    var isOpenNow = true
    var reviews: [Review] = []
    var additionalInfo: AdditionalInfo?
    var address: YelpLocation
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: latitude)!, longitude: CLLocationDegrees(exactly: longitude)!)
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let coordinates = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .coordinates)
        let dictionary = try container.decode([[String : String]].self, forKey: .categoriesContainer)
        
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
        transactions = try container.decode([String].self, forKey: .transactions)
        address = try container.decode(YelpLocation.self, forKey: .address)
        
        var tempCategories: [String] = []
        for i in dictionary {
            let category = i["title"]
            tempCategories.append(category!)
        }
        categories = tempCategories
        
    }
    
    init(id: String, name: String, latitude: Double, longitude: Double, url: String, imageURL: String, price: String, distance: Double, rating: Double, reviewCount: Int, categories: [String], transactions: [String], address: YelpLocation) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.url = url
        self.imageURL = imageURL
        self.price = price
        self.distance = distance
        self.rating = rating
        self.reviewCount = reviewCount
        self.categories = categories
        self.transactions = transactions
        self.address = address
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
        case categoriesContainer = "categories"
        case transactions
        case address = "location"
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



// MARK: Additional info
extension Restaurant {
    struct AdditionalInfo {
        #warning("need to complete")
        var phone: String
        var displayPhone: String
        var photos: [String]
        var isOpenNow: Bool
        private var jsonHours: [[String:Any]]
    }
}


// MARK: Yelp location

extension Restaurant {
    struct YelpLocation: Decodable {
        var address1: String
        var address2: String
        var address3: String
        var city: String
        var zipCode: String
        var country: String
        var state: String
        var displayAddress: [String]
        
        enum CodingKeys: String, CodingKey {
            case address1
            case address2
            case address3
            case city
            case zipCode = "zip_code"
            case country
            case state
            case displayAddress = "display_address"
        }
    }
}
