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
        case deleteEstablishment
        case updateEstablishment
        
        var requestMethod: HTTPMethod {
            switch self {
            case .userRestaurants, .restaurantDetail:
                return .get
            case .createEstablishment:
                return .post
            case .deleteEstablishment:
                return .delete
            case .updateEstablishment:
                return .put
            }
        }

        func url(establishment: Establishment?) -> String {
            switch self {
            case .userRestaurants, .createEstablishment:
                return "restaurant"
            case .restaurantDetail, .deleteEstablishment, .updateEstablishment:
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
        request?.responseJSON(queue: DispatchQueue.global(qos: .userInteractive), completionHandler: { [weak self] (response) in
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
    /// No accountId means it will be for the own user
    func getUserEstablishments(accountId: Int? = nil, completion: @escaping (Result<[Establishment], Errors.VisitEstablishment>) -> Void) {
        
        var params: Parameters = [:]
        if let accountId = accountId {
            params["account_id"] = accountId
        }
        
        let request = reqEstablishment(requestType: .userRestaurants, params: nil, establishment: nil)
        request?.responseJSON(queue: DispatchQueue.global(qos: .userInteractive), completionHandler: { [weak self] (response) in
            guard let self = self else { return }
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
                completion(Result.failure(.decoding))
            }
        })
    }
    
    func deleteEstablishment(establishment: Establishment, success: @escaping (Bool) -> Void) {
        let request = reqEstablishment(requestType: .deleteEstablishment, params: nil, establishment: establishment)
        guard let req = request else { success(false); return }
        req.response(queue: DispatchQueue.global(qos: .background)) { (result) in
            guard let code = result.response?.statusCode else {
                success(false)
                return
            }
            
            success(code == Network.deletedCode)
            
        }
    }
    
    
    func updateEstablishment(establishment: Establishment, success: @escaping (Bool) -> Void) {
        
        NotificationCenter.default.post(name: .establishmentUpdated, object: nil, userInfo: ["establishment": establishment])
        
        do {
            let data = try encoder.encode(establishment)
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            if var establishmentJson = json as? [String:Any] {
                establishmentJson["visits"] = nil
                
                let req = reqEstablishment(requestType: .updateEstablishment, params: establishmentJson, establishment: establishment)
                req?.response(queue: DispatchQueue.global(qos: .background), completionHandler: { (result) in
                    guard let code = result.response?.statusCode else {
                        success(false)
                        return
                    }
                    
                    success(code == Network.okCode)
                })
            }
            success(false)
        } catch {
            success(false)
        }
    }
    
}



