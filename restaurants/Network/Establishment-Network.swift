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
        case createEstablishment
        
        var requestMethod: HTTPMethod {
            switch self {
            case .userRestaurants:
                return .get
            case .createEstablishment:
                return .post
            }
        }
    }
    
    private func reqVisit(requestType: EstablishmentRequestType, params: Parameters?) -> DataRequest? {
        
        guard let token = Network.shared.account?.token else { return nil }
        
        let headers: HTTPHeaders = [
            "Authorization": "Token \(token)"
        ]
        
        var url: String {
            switch requestType {
            case .userRestaurants, .createEstablishment:
                return "restaurant"
            }
        }
        
        let request = AF.request(Network.djangoURL + url, method: requestType.requestMethod, parameters: params, headers: headers)
        return request
    }
    
    func getUserEstablishments(completion: @escaping (Result<[Establishment], Errors.VisitEstablishment>) -> Void) {
        let request = reqVisit(requestType: .userRestaurants, params: nil)
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
    
    func createEstablishmentOnly(from establishment: Establishment, completion: @escaping (Result<Establishment, Errors.VisitEstablishment>) -> Void) {
        
        do {
            let data = try encoder.encode(establishment)
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            if let establishmentJson = json as? [String:Any] {
                let request = reqVisit(requestType: .createEstablishment, params: establishmentJson)
                request?.responseJSON(completionHandler: { [weak self] (response) in
                    guard let self = self else { return }
                    guard let dataFound = response.data, response.error == nil else {
                        fatalError()
                    }
                    
                    do {
                        let establishment = try self.decoder.decode(Establishment.self, from: dataFound)
                        completion(Result.success(establishment))
                    } catch {
                        print(error)
                    }
                    
                })
            } else {
                completion(Result.failure(.encoding))
            }
            
            
        } catch {
            print(error)
        }
        
    }
    
    
}
