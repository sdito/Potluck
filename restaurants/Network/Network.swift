//
//  Network.swift
//  restaurants
//
//  Created by Steven Dito on 7/3/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import Alamofire
import AlamofireImage
import CoreLocation
import KeychainSwift

class Network {
    
    var account: Account? 
    var loggedIn: Bool {
        return account != nil
    }
    lazy var keychain: KeychainSwift = {
        let keychain = KeychainSwift()
        return keychain
    }()
    
    typealias YelpCategory = (alias: String?, title: String)
    typealias YelpCategories = [YelpCategory]
    var yelpCategories: YelpCategories = []
    private let baseCategories: YelpCategories = ["Delivery", "Takeout", "Outdoor Seating"].map({(nil, $0)})
    static let commonSearches: YelpCategories = [("pizza", "Pizza"),
                                                 ("chinese", "Chinese"),
                                                 ("mexican", "Mexican"),
                                                 ("thai", "Thai"),
                                                 ("burgers", "Burgers"),
                                                 ("italian", "Italian"),
                                                 ("seafood", "Seafood"),
                                                 ("steak", "Steakhouses"),
                                                 ("korean", "Korean"),
                                                 ("japanese", "Japanese"),
                                                 ("breakfast_brunch", "Breakfast & Brunch"),
                                                 ("vietnamese", "Vietnamese"),
                                                 ("sandwiches", "Sandwiches"),
                                                 ("vegetarian", "Vegetarian"),
                                                 ("sushi", "Sushi Bars"),
                                                 ("newamerican", "American")]
    
    
    static let yelpKey = "oXMAqpsZfTY1TpOVzrd-kq6IGlbN5iz-BkS0GLMFJv1loE-Mu1EJio8Ui3cFpk0r_rAzAnLK4ZVzH2aR7jNw6dYwFZznzmiwD4YzwjAvPOx8X8bGPOlM8dOWs_LOXnYx"
    static let yelpURL = "https://api.yelp.com/v3/"
    static let shared = Network()
    private init() {}
    
    enum YelpRequestType {
        case search
        case id
        case review
        case categories
    }
    
    struct RestaurantSearch {
        var yelpCategory: YelpCategory?
        var location: String?
        var coordinate: CLLocationCoordinate2D?
        
        enum LocationType {
            case currentLocation
            case mapLocation
            case text
        }
    }
    
    private func reqYelp(params: Parameters? = nil, restaurant: Restaurant? = nil, requestType: YelpRequestType) -> DataRequest {
        var url: String {
            switch requestType {
            case .search:
                return "businesses/search"
            case .id:
                return "businesses/\(restaurant!.id)"
            case .review:
                return "businesses/\(restaurant!.id)/reviews"
            case .categories:
                return "categories"
            }
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer \(Network.yelpKey)"]
        let request = AF.request(Network.yelpURL + url, parameters: params, headers: headers)
        return request
    }
    
    func getImage(url: String?, imageReturned: @escaping (UIImage) -> Void) {
        if let url = url {
            AF.request(url).responseImage { (response) in
                if let data = response.data {
                    if let image = UIImage(data: data) {
                        imageReturned(image)
                    }
                }
            }
        }
    }
    
    func getRestaurants(restaurantSearch: RestaurantSearch, filters: [String:Any], restaurantsReturned: @escaping (Result<[Restaurant], Error>) -> Void) {
        
        #warning("need to actually implement filters")
        
        var params: [String:Any] = [:]
        
        if let coordinate = restaurantSearch.coordinate {
            params = coordinate.getParams()
        }
        
        for key in filters.keys {
            params[key] = filters[key]
        }
        
        /*
         
         need to add YelpCategory to the searching
         need to add optional location text, to use when searching for a city specifically without a coordinate
         need to have either coordinate or location text
         
         YelpCategory = (alias: String?, title: String)
         if alias is nil, then parameter is 'term' and 'categories' is restaurants as before
         else parameter is 'categories' and the alias
         
         location for location text when no coordinate
         
         */
        
        
        if let yelpCategory = restaurantSearch.yelpCategory {
            
            if let alias = yelpCategory.alias {
                params["categories"] = alias
            } else {
                params["term"] = yelpCategory.title
                params["categories"] = "restaurants"
            }
            
        } else {
            params["categories"] = "restaurants"
        }
        
        if let locationText = restaurantSearch.location, restaurantSearch.coordinate == nil {
            if locationText != .currentLocation && locationText != .mapLocation {
                params["location"] = locationText
            }
            
        }
        
        
        
        let request = reqYelp(params: params, requestType: .search)
        request.responseJSON { (response) in
            switch response.result {
            case .success(let jsonAny):
                var restaurants: [Restaurant] = []
                if let json = jsonAny as? [String:Any], let restaurantsJson = json["businesses"] as? [[String:Any]] {
                    for r in restaurantsJson {
                        do {
                            let data = try JSONSerialization.data (withJSONObject: r, options: [])
                            do {
                                let restaurant = try JSONDecoder().decode(Restaurant.self, from: data)
                                restaurants.append(restaurant)
                            } catch {
                                print(r)
                                print(error)
                            }
                        } catch {
                            print(error)
                        }
                        
                    }
                }
                let sortedRestaurants = restaurants.sorted { (one, two) -> Bool in
                    one.distance < two.distance
                }
                restaurantsReturned(Result.success(sortedRestaurants))
            case .failure(let error):
                print("Error: getRestaurants")
                print(error)
            }
        }
    }
    
    func setFullRestaurantInfo(restaurant: Restaurant, complete: @escaping (Bool) -> Void) {
        #warning("need to complete")
        let request = reqYelp(restaurant: restaurant, requestType: .id)
        request.responseJSON { (response) in
            switch response.result {
            case .success(let jsonAny):
                if let json = jsonAny as? [String:Any] {
                    let data = try? JSONSerialization.data(withJSONObject: json, options: [])
                    if let d = data {
                        let additionalInfo = try? JSONDecoder().decode(Restaurant.AdditionalInfo.self, from: d)
                        restaurant.additionalInfo = additionalInfo
                        complete(true)
                    }
                }
            case .failure(let error):
                print("Error: setFullRestaurantInfo")
                print(error)
            }
        }
    }
    
    func setRestaurantReviewInfo(restaurant: Restaurant, complete: @escaping (Bool) -> Void) {
        
        let request = reqYelp(restaurant: restaurant, requestType: .review)
        request.responseJSON { (response) in
            switch response.result {
            case .success(let jsonAny):
                var reviews: [Review] = []
                if let json = jsonAny as? [String:Any], let reviewsJson = json["reviews"] as? [[String:Any]] {
                    for r in reviewsJson {
                        let data = try? JSONSerialization.data(withJSONObject: r, options: [])
                        if let d = data, let review = try? JSONDecoder().decode(Review.self, from: d) {
                            reviews.append(review)
                        } else {
                            print("Not going through if let for review decoding")
                            print(r)
                        }
                    }
                }
                // Have the reviews here
                restaurant.reviews = reviews
                complete(true)
            case .failure(let error):
                print("Error: setRestaurantReviewInfo")
                print(error)
            }
        }
        
    }
    
    func setUpInitialRun() {
        setCategoriesForYelpSearch()
        account = Account.readFromKeychain()
    }
    
    private func setCategoriesForYelpSearch() {
        let countryCode = "en_\(Locale.current.regionCode ?? "US")"
        let params: [String:Any] = [
            "locale": countryCode
        ]
        
        let request = reqYelp(params: params, requestType: .categories)
        request.responseJSON { (response) in
            switch response.result {
            case .success(let jsonAny):
                var results: YelpCategories = []
                guard let jsonData = jsonAny as? [String:Any] else { return }
                guard let arrayOfJson = jsonData["categories"] as? [[String:Any]] else { return }
                for element in arrayOfJson {
                    
                    if let aliases = element["parent_aliases"] as? [String], aliases.contains("restaurants") {
                        guard let alias = element["alias"] as? String, let title = element["title"] as? String else { return }
                        results.append((alias, title))
                    }
                    
                }
                self.yelpCategories = self.baseCategories + results
            case .failure(_):
                print("Error, something went wrong on setCategoriesForYelpSearch")
            }
        }
    }
    
    
    
}
