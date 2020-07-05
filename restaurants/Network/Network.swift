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
    
    static let yelpKey = "oXMAqpsZfTY1TpOVzrd-kq6IGlbN5iz-BkS0GLMFJv1loE-Mu1EJio8Ui3cFpk0r_rAzAnLK4ZVzH2aR7jNw6dYwFZznzmiwD4YzwjAvPOx8X8bGPOlM8dOWs_LOXnYx"
    static let yelpSearchURL = "https://api.yelp.com/v3/businesses/search"
    
    static let shared = Network()
    private init() {}
    
    private func req(params: Parameters?) -> DataRequest {
        let headers: HTTPHeaders = ["Authorization": "Bearer \(Network.yelpKey)"]
        let request = AF.request(Network.yelpSearchURL, parameters: params, headers: headers)
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
        let params = coordinate.getParams()
        let request = req(params: params)
        request.responseJSON { (response) in
            switch response.result {
            case .success(let jsonAny):
                var restaurants: [Restaurant] = []
                if let json = jsonAny as? [String:Any], let restaurantsJson = json["businesses"] as? [[String:Any]] {
                    for r in restaurantsJson {
                        let data = try? JSONSerialization.data (withJSONObject: r, options: [])
                        if let data = data, let restaurant = try? JSONDecoder().decode(Restaurant.self, from: data) {
                            restaurants.append(restaurant)
                        }
                    }
                }
                restaurantsReturned(Result.success(restaurants))
            case .failure(_):
                print("Error")
            }
        }
        
    }
    
    
}
