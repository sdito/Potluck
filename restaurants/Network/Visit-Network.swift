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
        case updateVisit
        
        var requestMethod: HTTPMethod {
            switch self {
            case .userFeed:
                return .get
            case .userPost:
                return .post
            case .deleteVisit:
                return .delete
            case .updateVisit:
                return .put
            }
        }
        
        func url(visit: Visit?) -> String {
            switch self {
            case .userFeed, .userPost:
                return "visit"
            case .deleteVisit, .updateVisit:
                return "visit/\(visit!.djangoOwnID)/"
            }
        }
    }
    
    enum FeedType: String {
        case user
        case friends
    }
    
    private func reqVisit(params: Parameters?,
                          visit: Visit?,
                          requestType: VisitRequestType,
                          mainImage: UIImage? = nil,
                          otherImages: [UIImage]? = nil,
                          tags: [String]? = nil) -> DataRequest? {
        guard let token = Network.shared.account?.token else { return nil }
        let headers: HTTPHeaders = ["Authorization": "Token \(token)"]
        
        let requestUrl = Network.djangoURL + requestType.url(visit: visit)
        
        switch requestType {
        case .deleteVisit, .userFeed, .updateVisit:
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
                
                if let tags = tags {
                    for i in 0..<tags.count {
                        let tag = tags[i]
                        let key = "tags[\(i)]display"
                        multipartFormData.append(tag.data(using: .utf8)!, withName: key)
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
        let req = reqVisit(params: nil, visit: visit, requestType: .deleteVisit)
        req?.response(queue: DispatchQueue.global(qos: .background), completionHandler: { (result) in
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
    
    
    func userPostNotVisited(establishment: Establishment,
                            mainImage: UIImage,
                            mainImageDate: Date,
                            otherImages: [UIImage]?,
                            comment: String?,
                            rating: Float?,
                            tags: [String]?,
                            progressView: ProgressView?,
                            completion: @escaping (Result<Visit,Errors.VisitEstablishment>) -> Void) {
        
        // add everything into the params for the request
        do {
            let data = try encoder.encode(establishment)
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            if var establishmentJson = json as? [String:Any] {
                
                if let comment = comment, comment != "" {
                    establishmentJson["comment"] = comment
                }
                
                if let rating = rating {
                    establishmentJson["rating"] = rating
                }
                
                establishmentJson["date_visited"] = self.dateFormatter.string(from: mainImageDate)
                
                let req = reqVisit(params: establishmentJson, visit: nil, requestType: .userPost, mainImage: mainImage, otherImages: otherImages, tags: tags)
                req?.responseJSON(queue: DispatchQueue.global(qos: .userInteractive), completionHandler: { [weak self] (response) in
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
                        DispatchQueue.main.async {
                            progressView?.updateProgress(to: Float(progress.fractionCompleted))
                        }
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
    

    func userPostAlreadyVisited(djangoID: Int,
                                mainImage: UIImage,
                                mainImageDate: Date,
                                otherImages: [UIImage]?,
                                comment: String?,
                                rating: Float?,
                                tags: [String]?,
                                progressView: ProgressView?,
                                completion: @escaping (Result<Visit,Errors.VisitEstablishment>) -> Void) {

        
        var params: Parameters = ["restaurant_id":djangoID]
        if let comment = comment, comment != "" {
            params["comment"] = comment
        }
        
        if let rating = rating {
            params["rating"] = rating
        }
        
        params["date_visited"] = self.dateFormatter.string(from: mainImageDate)
        
        let request = reqVisit(params: params, visit: nil, requestType: .userPost, mainImage: mainImage, otherImages: otherImages, tags: tags)
        request?.responseJSON(queue: DispatchQueue.global(qos: .userInteractive), completionHandler: { [weak self] (response) in
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
                DispatchQueue.main.async {
                    progressView?.updateProgress(to: Float(progress.fractionCompleted))
                }
                
            }
        }
    }
    
    // Get the user's own posts or friends posts
    func getVisitFeed(feedType: FeedType, completion: @escaping (Result<Visit.VisitFeedDecoder, Errors.VisitEstablishment>) -> Void) {
        
        let params: Parameters = ["type": feedType.rawValue]
        
        let req = reqVisit(params: params, visit: nil, requestType: .userFeed)
        guard let request = req else { completion(Result.failure(.noAccount)); return}
        
        request.responseJSON(queue: DispatchQueue.global(qos: .userInteractive)) { (response) in
            guard let data = response.data, response.error == nil else {
                print(response.error as Any)
                completion(Result.failure(.other(alamoFireError: response.error)))
                return
            }
            do {
                let visits = try self.decoder.decode(Visit.VisitFeedDecoder.self, from: data)
                completion(Result.success(visits))
            } catch let error {
                print(error.localizedDescription)
                completion(Result.failure(.decoding))
            }
        }
    }
    
    func updateVisit(visit: Visit, rating: Float?, newComment: String?, newTags: [String]?, success: @escaping (Bool) -> Void) {
        
        var params: [String:Any] = [:]
        
        if let rating = rating {
            params["rating"] = rating
        }
        
        if let comment = newComment {
            params["comment"] = comment
        }
        
        let tags = newTags ?? visit.tags.map({$0.display}) // if own tags are not sent back when updating visit, it removes the tag, so lets just take a shortcut and send the tags again
        if tags.count > 0 {
            for i in 0..<tags.count {
                let tag = tags[i]
                let key = "tags[\(i)]display"
                params[key] = tag
            }
        } else {
            params["tags"] = nil
        }
        
        let req = reqVisit(params: params, visit: visit, requestType: .updateVisit)
        
        req?.response(queue: DispatchQueue.global(qos: .background), completionHandler: { (result) in
            guard let code = result.response?.statusCode else {
                success(false)
                return
            }
            success(code == Network.okCode)
            
        })
    }
    
    
}
