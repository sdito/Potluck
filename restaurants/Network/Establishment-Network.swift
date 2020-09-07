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
        case restaurantDetail
        
        var requestMethod: HTTPMethod {
            switch self {
            case .userRestaurants, .restaurantDetail:
                return .get
            case .createEstablishment:
                return .post
            }
        }
        
        func url(establishment: Establishment?) -> String {
            switch self {
            case .userRestaurants, .createEstablishment:
                return "restaurant"
            case .restaurantDetail:
                return "restaurant/\(establishment!.djangoID!)/"
            }
        }
        
    }
    
    private func reqEstablishment(requestType: EstablishmentRequestType, params: Parameters?, establishment: Establishment?) -> DataRequest? {
        
        guard let token = Network.shared.account?.token else { return nil }
        
        let headers: HTTPHeaders = [
            "Authorization": "Token \(token)"
        ]
        
        let urlPortion = requestType.url(establishment: establishment)
        
        let request = AF.request(Network.djangoURL + urlPortion, method: requestType.requestMethod, parameters: params, headers: headers)
        return request
    }
    
    func getEstablishmentDetail(from establishment: Establishment, completion: @escaping (Result<Establishment, Errors.VisitEstablishment>) -> Void) {
        let request = reqEstablishment(requestType: .restaurantDetail, params: nil, establishment: establishment)
        request?.responseJSON(completionHandler: { [weak self] (response) in
            guard let self = self else { return }
            guard let data = response.data, response.error == nil else {
                completion(Result.failure(.other(alamoFireError: response.error)))
                return
            }
            
            do {
                let establishment = try self.decoder.decode(Establishment.self, from: data)
                completion(Result.success(establishment))
            } catch {
                print(error)
                completion(Result.failure(.decoding))
            }
            
        })
    }
    
    func getUserEstablishments(completion: @escaping (Result<[Establishment], Errors.VisitEstablishment>) -> Void) {
        let request = reqEstablishment(requestType: .userRestaurants, params: nil, establishment: nil)
        request?.responseJSON(completionHandler: { (response) in
            guard let data = response.data, response.error == nil else {
                completion(Result.failure(.other(alamoFireError: response.error)))
                return
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
        #warning("need to actually use")
        do {
            let data = try encoder.encode(establishment)
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            
            if let establishmentJson = json as? [String:Any] {
                let request = reqEstablishment(requestType: .createEstablishment, params: establishmentJson, establishment: nil)
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
