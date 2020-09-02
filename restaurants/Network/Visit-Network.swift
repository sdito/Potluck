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
                
                multipartFormData.append(imageData!, withName: "main_image", fileName: "\(Network.shared.account?.username ?? "anon_user")-\(Int(Date().timeIntervalSince1970))-\(String.randomString(6)).png",mimeType: "jpg/png")
                for (key, value) in params {
                    multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
                }
            }, to: requestUrl, headers: headers)
            return req
        }
    }
    
    func userPostNotVisited(establishment: Establishment, mainImage: UIImage, comment: String?, progressView: ProgressView?, completion: @escaping (Result<Visit,Errors.VisitEstablishment>) -> Void) {
        // add everything into the params for the request
        #warning("need to do testing on this")
        do {
            let data = try encoder.encode(establishment)
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            if var establishmentJson = json as? [String:Any] {
                
                if let comment = comment {
                    establishmentJson["comment"] = comment
                }
                
                let req = reqVisit(params: establishmentJson, requestType: .userPost, image: mainImage)
                req?.responseJSON(completionHandler: { [weak self] (response) in
                    guard let self = self else { return }
                    guard let data = response.data, response.error == nil else {
                        completion(Result.failure(.other(alamoFireError: response.error)))
                        return
                    }
                    
                    do {
                        let visit = try self.decoder.decode(Visit.SingleVisitDecoder.self, from: data).visit
                        // maybe get establishment
                        establishment.djangoID = visit.djangoRestaurantID
                        completion(Result.success(visit))
                        
                    } catch {
                        print(error)
                        completion(Result.failure(.decoding))
                    }
                    
                })
                .uploadProgress { progress in
                    if progressView != nil {
                        progressView?.updateProgress(to: Float(progress.fractionCompleted))
                    }
                }
                
            } else {
                completion(Result.failure(.encoding))
            }
        } catch {
            print(error)
            completion(Result.failure(.encoding))
        }
    }
    
    
    func userPostAlreadyVisited(djangoID: Int, mainImage: UIImage, comment: String?, progressView: ProgressView?, completion: @escaping (Result<Visit,Errors.VisitEstablishment>) -> Void) {
        var params: Parameters = ["restaurant_id":djangoID]
        if let comment = comment, comment != "" {
            params["comment"] = comment
        }
        let request = reqVisit(params: params, requestType: .userPost, image: mainImage)
        request?.responseJSON(completionHandler: { [weak self] (response) in
            guard let self = self else { return }
            guard let data = response.data, response.error == nil else {
                completion(Result.failure(.other(alamoFireError: response.error)))
                return
            }
            
            #warning("actually worked wtf")
            
            do {
                let visit = try self.decoder.decode(Visit.SingleVisitDecoder.self, from: data)
                completion(Result.success(visit.visit))
            } catch {
                print(error)
                completion(Result.failure(.decoding))
            }
        })
        .uploadProgress { progress in
            if progressView != nil {
                progressView?.updateProgress(to: Float(progress.fractionCompleted))
            }
        }
    }
    
    
    // Get the user's own posts
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
