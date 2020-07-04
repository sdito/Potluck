//
//  Network.swift
//  restaurants
//
//  Created by Steven Dito on 7/3/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import Alamofire
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

    
    func getRestaurants(coordinate: CLLocationCoordinate2D, restaurantsReturned: @escaping (Result<[Restaurant], Error>) -> Void) {
        let params = coordinate.getParams()
        let request = req(params: params)
        request.responseJSON { (response) in
            switch response.result {
            case .success(let json):
                if let data = json as? Data {
                    if let restaurants = try? JSONDecoder().decode([Restaurant].self, from: data) {
                        restaurantsReturned(Result.success(restaurants))
                    }
                    print("Success, but not restaurants")
                } else {
                    print(json)
                }
                
            case .failure(let error):
                print("There is a failure: \(error.localizedDescription)")
                if let err = error.underlyingError {
                    #warning("make sure this always goes to this error")
                    restaurantsReturned(Result.failure(err))
                }
            }
        }
        
    }
    
    
}
