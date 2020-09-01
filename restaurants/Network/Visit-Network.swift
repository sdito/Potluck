//
//  Visit-Network.swift
//  restaurants
//
//  Created by Steven Dito on 8/25/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import Alamofire
import CoreLocation


extension Network {
    
    private enum VisitRequestType {
        case userFeed
        case userPost
        var requestMethod: HTTPMethod {
            switch self {
            case .userFeed:
                return .get
            case .userPost:
                return .post
            }
        }
        
        var url: String {
            switch self {
            case .userFeed, .userPost:
                return "visit"
            }
        }
        
    }
    
    // Get the user's own posts
    private func reqVisit(params: Parameters?, requestType: VisitRequestType, image: UIImage?) -> DataRequest? {
        
        guard let token = Network.shared.account?.token else { return nil }
        
        let headers: HTTPHeaders = [
            "Authorization": "Token \(token)"
        ]
        
        let requestUrl = Network.djangoURL + requestType.url
        
        switch requestType {
        case .userFeed:
            let request = AF.request(requestUrl, method: requestType.requestMethod, parameters: params, headers: headers)
            return request
        case .userPost:
            guard let image = image, let params = params else { return nil }
            let req = AF.upload(multipartFormData: { (multipartFormData) in
                let imageData = image.jpegData(compressionQuality: 0.8)
                multipartFormData.append(imageData!, withName: "main_image", fileName: "\(Network.shared.account?.username ?? "anon_user")\(Date().timeIntervalSince1970.rounded()).png",mimeType: "jpg/png")
                for (key, value) in params {
                    multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
                }
            }, to: requestUrl, headers: headers)
            
            return req
            
            
            
        }
        
        
    }
    
    
    func userPost(establishment: Establishment, mainImage: UIImage, completion: @escaping (Result<Visit,Errors.VisitEstablishment>) -> Void) {
        
        var params: Parameters = ["comment": "test comment"]
        
        #warning("need to complete")
        if let djangoID = establishment.djangoID {
            // Establishment already exists, just add visit with the djangoID
            params["restaurant_id"] = djangoID
        } else {
            // Need to also create an establishment
        }
        
        
        let request = reqVisit(params: params, requestType: .userPost, image: mainImage)
        
        
        request?.responseJSON(completionHandler: { (response) in
            for _ in 1...10 {
                print(response.value)
            }
        })
        
        
    
    }
    
    func userPost(restaurant: Restaurant, completion: @escaping (Result<Visit,Errors.VisitEstablishment>) -> Void) {
        #warning("need to complete")
    }
    
    func userPost(name: String, address: String, coordinate: CLLocationCoordinate2D, completion: @escaping (Result<Visit,Errors.VisitEstablishment>) -> Void) {
        #warning("need to complete")
    }
    
    func getUserFeed(completion: @escaping (Result<[Visit], Errors.VisitEstablishment>) -> Void) {
        let req = reqVisit(params: nil, requestType: .userFeed, image: nil)
        
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
