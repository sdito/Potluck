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

class Network {
    
    typealias YelpCategories = [(alias: String?, title: String)]
    var yelpCategories: YelpCategories = []
    
    static let yelpKey = "oXMAqpsZfTY1TpOVzrd-kq6IGlbN5iz-BkS0GLMFJv1loE-Mu1EJio8Ui3cFpk0r_rAzAnLK4ZVzH2aR7jNw6dYwFZznzmiwD4YzwjAvPOx8X8bGPOlM8dOWs_LOXnYx"
    static let yelpURL = "https://api.yelp.com/v3/"
    static let shared = Network()
    private init() {}
    
    enum RequestType {
        case search
        case id
        case review
        case categories
    }
    
    private func req(params: Parameters? = nil, restaurant: Restaurant? = nil, requestType: RequestType) -> DataRequest {
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
    
    func getRestaurants(coordinate: CLLocationCoordinate2D, restaurantsReturned: @escaping (Result<[Restaurant], Error>) -> Void) {
        var params = coordinate.getParams()
        params["categories"] = "restaurants"
        let request = req(params: params, requestType: .search)
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
        let request = req(restaurant: restaurant, requestType: .id)
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
        
        let request = req(restaurant: restaurant, requestType: .review)
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
    }
    
    private func setCategoriesForYelpSearch() {
        let countryCode = "en_\(Locale.current.regionCode ?? "US")"
        let params: [String:Any] = [
            "locale": countryCode
        ]
        
        let request = req(params: params, requestType: .categories)
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
                self.yelpCategories = results
            case .failure(_):
                print("Error, something went wrong on setCategoriesForYelpSearch")
            }
        }
    }
    
    
}
