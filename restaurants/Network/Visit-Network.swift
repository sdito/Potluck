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
        case deleteVisit
        
        var requestMethod: HTTPMethod {
            switch self {
            case .userFeed:
                return .get
            case .userPost:
                return .post
            case .deleteVisit:
                return .delete
            }
        }
        
        func url(visit: Visit?) -> String {
            switch self {
            case .userFeed, .userPost:
                return "visit"
            case .deleteVisit:
                return "visit/\(visit!.djangoOwnID)/"
            }
        }
    }
    
    
    
    private func reqVisit(params: Parameters?, visit: Visit?, requestType: VisitRequestType, mainImage: UIImage?, otherImages: [UIImage]?) -> DataRequest? {
        guard let token = Network.shared.account?.token else { return nil }
        let headers: HTTPHeaders = [
            "Authorization": "Token \(token)"
        ]
        
        let requestUrl = Network.djangoURL + requestType.url(visit: visit)
        
        switch requestType {
        case .deleteVisit:
            let request = AF.request(requestUrl, method: requestType.requestMethod, parameters: params, headers: headers)
            return request
        case .userFeed:
            let request = AF.request(requestUrl, method: requestType.requestMethod, parameters: params, headers: headers)
            return request
        case .userPost:
            guard let mainImage = mainImage, let params = params else { return nil }
            
            
            let req = AF.upload(multipartFormData: { (multipartFormData) in
            
                guard let imageData = mainImage.jpegData(compressionQuality: 0.8) else { return }
                //"main_image".data(using: .utf8) else { return }//
                multipartFormData.append(imageData, withName: "main_image", fileName: "\(Network.shared.account?.username ?? "anon_user")-\(Int(Date().timeIntervalSince1970))-\(String.randomString(6))-main.png", mimeType: "jpg/png")
                
                // add the other photos here, if they exist
                if let otherImages = otherImages {
                    for i in 0..<otherImages.count {

                        let otherImage = otherImages[i]
                        guard let otherImageData = otherImage.jpegData(compressionQuality: 0.8) else { continue }
                        
                        multipartFormData.append(otherImageData, withName: "other_images[\(i)]image", fileName: "\(Network.shared.account?.username ?? "anon_user")-\(Int(Date().timeIntervalSince1970))-\(String.randomString(6))-\(i).png", mimeType: "jpg/png")
                    }
                }
                
                for (key, value) in params {
                    multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
                }
                
            }, to: requestUrl, headers: headers)
            return req
        }
    }
    
    func deleteVisit(visit: Visit, success: @escaping (Bool) -> Void) {
        let req = reqVisit(params: nil, visit: visit, requestType: .deleteVisit, mainImage: nil, otherImages: nil)
        req?.response(completionHandler: { (result) in
            guard let code = result.response?.statusCode else {
                success(false)
                return
            }
            
            if code == Network.deletedCode {
                success(true)
            } else {
                success(false)
            }
        })
    }
    
    func userPostNotVisited(establishment: Establishment, mainImage: UIImage, otherImages: [UIImage]?, comment: String?, progressView: ProgressView?, completion: @escaping (Result<Visit,Errors.VisitEstablishment>) -> Void) {
        // add everything into the params for the request
        #warning("need to do testing on this")
        do {
            let data = try encoder.encode(establishment)
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            if var establishmentJson = json as? [String:Any] {
                
                if let comment = comment {
                    establishmentJson["comment"] = comment
                }
                
                let req = reqVisit(params: establishmentJson, visit: nil, requestType: .userPost, mainImage: mainImage, otherImages: otherImages)
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
    
    
    func userPostAlreadyVisited(djangoID: Int, mainImage: UIImage, otherImages: [UIImage]?, comment: String?, progressView: ProgressView?, completion: @escaping (Result<Visit,Errors.VisitEstablishment>) -> Void) {
        var params: Parameters = ["restaurant_id":djangoID]
        if let comment = comment, comment != "" {
            params["comment"] = comment
        }
        let request = reqVisit(params: params, visit: nil, requestType: .userPost, mainImage: mainImage, otherImages: otherImages)
        request?.responseJSON(completionHandler: { [weak self] (response) in
            
            for _ in 1...10 {
                print(response.value)
            }
            
            guard let self = self else { return }
            guard let data = response.data, response.error == nil else {
                completion(Result.failure(.other(alamoFireError: response.error)))
                return
            }
            
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
        let req = reqVisit(params: nil, visit: nil, requestType: .userFeed, mainImage: nil, otherImages: nil)
        
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
