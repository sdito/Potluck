//
//  Restaurant.swift
//  restaurants
//
//  Created by Steven Dito on 7/3/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//
import UIKit
import CoreLocation

class Restaurant: Decodable {
    var id: String
    var name: String
    var latitude: Double
    var longitude: Double
    var url: String
    var imageURL: String
    var price: String?
    var distance: Double
    var rating: Double
    var reviewCount: Int
    var categories: [String]
    var transactions: [YelpTransaction]
    var reviews: [Review] = []
    var additionalInfo: AdditionalInfo?
    var address: YelpLocation
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(exactly: latitude)!, longitude: CLLocationDegrees(exactly: longitude)!)
    }
    
    var openNowDescription: NSAttributedString? {
        
        let attributedStringGreenColor = [NSAttributedString.Key.foregroundColor : UIColor.systemGreen]
        let attributedStringRedColor = [NSAttributedString.Key.foregroundColor : UIColor.systemRed]
        
        let boolean = self.additionalInfo?.hours.first?.isOpenNow
        if boolean == true {
            return NSAttributedString(string: "Open now", attributes: attributedStringGreenColor)
        } else if boolean == false {
            return NSAttributedString(string: "Closed now", attributes: attributedStringRedColor)
        } else {
            return nil
        }
        
    }
    
    var systemTime: [SystemTime]? = {
        
        if let timesFound = additionalInfo?.hours {
            var systemTimes: [SystemTime] = []
            for time in timesFound {
                for open in time.open {
                    // have the open value now, now just need to convert it
                    let dayStart = open.start
                    let dayEnd = open.end
                    
                    let newSystemTime = SystemTime(rawStartValue: Int(dayStart) ?? 0,
                                                   weekday: Date.convertWeekdayFromYelpToStandard(yelpDate: open.day),
                                                   start: dayStart.convertFromStringToDisplayTime(),
                                                   end: dayEnd.convertFromStringToDisplayTime())
                    
                    systemTimes.append(newSystemTime)
                    
                }
            }
            return systemTimes
        } else {
            return nil
        }
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
        price = try? container.decode(String?.self, forKey: .price)
        distance = try container.decode(Double.self, forKey: .distance)
        rating = try container.decode(Double.self, forKey: .rating)
        reviewCount = try container.decode(Int.self, forKey: .reviewCount)
        transactions = try container.decode([YelpTransaction].self, forKey: .transactions)
        address = try container.decode(YelpLocation.self, forKey: .address)
        
        var tempCategories: [String] = []
        for i in dictionary {
            let category = i["title"]
            tempCategories.append(category!)
        }
        categories = tempCategories
        
    }
    
    init(id: String, name: String, latitude: Double, longitude: Double, url: String, imageURL: String, price: String, distance: Double, rating: Double, reviewCount: Int, categories: [String], transactions: [YelpTransaction], address: YelpLocation) {
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
    
    
    enum YelpTransaction: String, Decodable, CaseIterable {
        case pickup
        case delivery
        case restaurantReservation = "restaurant_reservation"
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
    struct AdditionalInfo: Decodable {
        var phone: String
        var displayPhone: String
        var photos: [String]
        var hours: [Hours]
        

        
        enum CodingKeys: String, CodingKey {
            case phone
            case displayPhone = "display_phone"
            case photos
            case hours
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            phone = try container.decode(String.self, forKey: .phone)
            displayPhone = try container.decode(String.self, forKey: .displayPhone)
            photos = try container.decode([String].self, forKey: .photos)
            hours = try container.decode([Hours].self, forKey: .hours)
            
        }
    }
    
    struct Hours: Decodable {
        var open: [Day]
        var hoursType: String
        var isOpenNow: Bool
        
        enum CodingKeys: String, CodingKey {
            case open
            case hoursType = "hours_type"
            case isOpenNow = "is_open_now"
        }
        
        func test() {
            
        }
        
    }
    
    struct Day: Decodable {
        var isOvernight: Bool
        var start: String
        var end: String
        var day: Int
        
        enum CodingKeys: String, CodingKey {
            case isOvernight = "is_overnight"
            case start
            case end
            case day
        }
    }
    
}


// MARK: Yelp location

extension Restaurant {
    struct YelpLocation: Decodable {
        var address1: String
        var address2: String?
        var address3: String?
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



extension Restaurant {
    #warning("need to use")
    struct SystemTime {
        
        var rawStartValue: Int // used for ordering
        var weekday: Weekday
        var start: String
        var end: String
        
        enum Weekday {
            case sunday
            case monday
            case tuesday
            case wednesday
            case thursday
            case friday
            case saturday
        }

        
        
    }
}
