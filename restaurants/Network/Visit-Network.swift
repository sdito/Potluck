//
//  Visit-Network.swift
//  restaurants
//
//  Created by Steven Dito on 8/25/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import Alamofire

extension Network {
    
    private enum VisitRequestType {
        case userFeed
        
        var requestMethod: HTTPMethod {
            switch self {
            case .userFeed:
                return .get
            }
        }
        
    }
    
    // Get the user's own posts
    private func reqVisit(params: Parameters?, requestType: VisitRequestType) -> DataRequest? {
        
        guard let token = Network.shared.account?.token else { return nil }
        
        let headers: HTTPHeaders = [
            "Authorization": "Token \(token)"
        ]
        
        var url: String {
            switch requestType {
            case .userFeed:
                return "visit"
            }
        }
        
        let request = AF.request(Network.djangoURL + url, method: requestType.requestMethod, parameters: params, headers: headers)
        return request
    }
    
    #warning("need to complete")
    func getUserFeed(completion: @escaping (Result<[Visit], Errors.Visit>) -> Void) {
        let req = reqVisit(params: nil, requestType: .userFeed)
        
        guard let request = req else {
            // need to handle
            completion(Result.failure(.noAccount))
            return
        }
        
        request.responseJSON { (response) in
            guard let data = response.data, response.error == nil else {
                fatalError()
            }
            do {
                let visits = try self.decoder.decode(Visit.VisitDecoder.self, from: data)
                guard let vis = visits.visits else { return }
                completion(Result.success(vis))
            } catch {
                print(error)
                fatalError()
            }
        }
    }
    
}
