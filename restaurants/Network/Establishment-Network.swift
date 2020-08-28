//
//  Establishment-Network.swift
//  restaurants
//
//  Created by Steven Dito on 8/27/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import Alamofire


extension Network {
    
    private enum EstablishmentRequestType {
        case userRestaurants
        
        var requestMethod: HTTPMethod {
            switch self {
            case .userRestaurants:
                return .get
            }
        }
    }
    
    private func reqVisit(requestType: EstablishmentRequestType) -> DataRequest? {
        
        guard let token = Network.shared.account?.token else { return nil }
        
        let headers: HTTPHeaders = [
            "Authorization": "Token \(token)"
        ]
        
        var url: String {
            switch requestType {
            case .userRestaurants:
                return "restaurant"
            }
        }
        
        let request = AF.request(Network.djangoURL + url, method: requestType.requestMethod, parameters: nil, headers: headers)
        return request
    }
    
    func getUserEstablishments(completion: @escaping (Result<[Establishment], Errors.VisitEstablishment>) -> Void) {
        let request = reqVisit(requestType: .userRestaurants)
        request?.responseJSON(completionHandler: { (response) in
            guard let data = response.data, response.error == nil else {
                fatalError()
            }
            
            do {
                let establishments = try self.decoder.decode(Establishment.EstablishmentDecoder.self, from: data)
                guard let establishmentsFound = establishments.restaurants else { return }
                completion(Result.success(establishmentsFound))
            } catch {
                print(error)
                fatalError()
            }
            
        })
    }
    
}
