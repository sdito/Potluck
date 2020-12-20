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
        case getPreSignedPost
        case deleteStandardTag
        
        var requestMethod: HTTPMethod {
            switch self {
            case .userFeed, .getPreSignedPost:
                return .get
            case .userPost:
                return .post
            case .deleteVisit, .deleteStandardTag:
                return .delete
            case .updateVisit:
                return .put
            }
        }
        
        func url(int: Int?) -> String {
            switch self {
            case .userFeed, .userPost:
                return "visit"
            case .deleteVisit, .updateVisit:
                return "visit/\(int!)/"
            case .getPreSignedPost:
                return "generatepresignedpost"
            case .deleteStandardTag:
                return "tagdetail/\(int!)/"
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
                          mainImage: String? = nil,
                          otherImages: [String]? = nil,
                          tags: [String]? = nil,
                          primaryKey: Int? = nil) -> DataRequest? {
        guard let token = Network.shared.account?.token else { return nil }
        let headers: HTTPHeaders = ["Authorization": "Token \(token)"]
        
        let requestUrl = Network.djangoURL + requestType.url(int: visit?.djangoOwnID ?? primaryKey)
        
        switch requestType {
        case .deleteVisit, .userFeed, .updateVisit, .getPreSignedPost, .deleteStandardTag:
            let request = AF.request(requestUrl, method: requestType.requestMethod, parameters: params, headers: headers)
            return request
        case .userPost:
            guard let params = params else { return nil }
            let req = AF.upload(multipartFormData: { (multipartFormData) in
                
                if let mainImage = mainImage {
                    multipartFormData.append(mainImage.data(using: .utf8)!, withName: "main_image")
                }
                
                // add the other photos here, if they exist
                if let otherImages = otherImages {
                    for i in 0..<otherImages.count {
                        let value = otherImages[i]
                        let key = "other_images[\(i)]image"
                        multipartFormData.append(value.data(using: .utf8)!, withName: key)
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
                            mainImage: UIImage?,
                            mainImageDate: Date,
                            otherImages: [UIImage]?,
                            comment: String?,
                            rating: Float?,
                            tags: [String]?,
                            progressView: ProgressView?,
                            completion: @escaping (Result<Visit,Errors.VisitEstablishment>) -> Void) {
        
        
        var mainImagePath: String?
        var otherImagePaths: [String]?
        
        var orderedImages: [UIImage] = []
        
        if let mainImage = mainImage {
            orderedImages.append(mainImage)
        }
        
        if let otherImage = otherImages {
            orderedImages.append(contentsOf: otherImage)
        }
        
        Network.shared.uploadImagesToAwsWithCompletion(orderedImages: orderedImages) { [unowned self] (urlsFound) in
            if var urls = urlsFound, urls.count > 0 {
                mainImagePath = urls.removeFirst()
                otherImagePaths = urls
            }
            
            
            // add everything into the params for the request
            do {
                let data = try self.encoder.encode(establishment)
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                if var establishmentJson = json as? [String:Any] {
                    
                    if let comment = comment, comment != "" {
                        establishmentJson["comment"] = comment
                    }
                    
                    if let rating = rating {
                        establishmentJson["rating"] = rating
                    }
                    
                    establishmentJson["date_visited"] = self.dateFormatter.string(from: mainImageDate)
                    
                    let req = reqVisit(params: establishmentJson, visit: nil, requestType: .userPost, mainImage: mainImagePath, otherImages: otherImagePaths, tags: tags)
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
    }
    
    
    func userPostAlreadyVisited(djangoID: Int,
                                mainImage: UIImage?,
                                mainImageDate: Date,
                                otherImages: [UIImage]?,
                                comment: String?,
                                rating: Float?,
                                tags: [String]?,
                                progressView: ProgressView?,
                                completion: @escaping (Result<Visit,Errors.VisitEstablishment>) -> Void) {
        
        var mainImagePath: String?
        var otherImagePaths: [String]?
        
        var orderedImages: [UIImage] = []
        
        if let mainImage = mainImage {
            orderedImages.append(mainImage)
        }
        
        if let otherImage = otherImages {
            orderedImages.append(contentsOf: otherImage)
        }
        
        
        Network.shared.uploadImagesToAwsWithCompletion(orderedImages: orderedImages) { [unowned self] (urlsFound) in
            if var urls = urlsFound, urls.count > 0 {
                mainImagePath = urls.removeFirst()
                otherImagePaths = urls
            }
            
            var params: Parameters = ["restaurant_id":djangoID]
            if let comment = comment, comment != "" {
                params["comment"] = comment
            }
            
            if let rating = rating {
                params["rating"] = rating
            }
            
            params["date_visited"] = self.dateFormatter.string(from: mainImageDate)
            
            let request = reqVisit(params: params, visit: nil, requestType: .userPost, mainImage: mainImagePath, otherImages: otherImagePaths, tags: tags)
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
    
    func getPreSignedPostAWS(count: Int, urlsFound: @escaping (Result<[PreSignedPost], Errors.VisitEstablishment>) -> Void) {
        let params: Parameters = ["count": count]
        let req = reqVisit(params: params, visit: nil, requestType: .getPreSignedPost)
        req?.responseJSON(queue: .global(qos: .userInteractive), completionHandler: { (response) in
            guard let data = response.data, response.error == nil else {
                urlsFound(Result.failure(.other(alamoFireError: response.error)))
                return
            }
            
            do {
                let preSignedPosts = try self.decoder.decode([PreSignedPost].self, from: data)
                urlsFound(Result.success(preSignedPosts))
            } catch {
                urlsFound(Result.failure(.decoding))
            }
        })
    }
    
    #warning("do the progress stuff with this one, average of all the requests")
    func uploadImagesToAwsWithCompletion(orderedImages: [UIImage], allOrderedUrls: @escaping ([String]?) -> Void) {
        guard orderedImages.count > 0 else { allOrderedUrls(nil); return }
        getPreSignedPostAWS(count: orderedImages.count) { (result) in
            switch result {
            case .success(let postRequests):
                guard orderedImages.count == postRequests.count else {
                    print("Something went wrong, different count of images and post requests")
                    return
                }
                var successfulUrls: [String?] = Array.init(repeating: nil, count: orderedImages.count)
                
                for (index, postRequest) in postRequests.enumerated() {
                    postRequest.uploadImage(image: orderedImages[index]) { (done) in
                        if done {
                            successfulUrls[index] = postRequest.fileName
                            // check if all the requests are completed, if so return them from map
                            if successfulUrls.nonNilElementsMatchCount() {
                                let urlsSucceeded = successfulUrls.map({$0!})
                                allOrderedUrls(urlsSucceeded)
                            }
                        } else {
                            print("Exiting here, wasn't able to upload")
                            allOrderedUrls(nil)
                            return
                        }
                    }
                }
            case .failure(_):
                print("Unable to get post requests")
            }
        }
    }
    
    func deleteStandardTag(tag: Tag, success: @escaping (Bool) -> Void) {
        guard let id = tag.id else { return }
        let req = reqVisit(params: nil, visit: nil, requestType: .deleteStandardTag, primaryKey: id)
        req?.responseData(completionHandler: { (completion) in
            success(completion.response?.statusCode == Network.deletedCode)
            NotificationCenter.default.post(name: .standardTagDeleted, object: nil, userInfo: ["tag": tag])
        })
    }
    
    func editPhotosOnVisit(imageTransfer: [ImageTransfer], visit: Visit?) {
        #warning("need to complete")
        let newTransfers = imageTransfer.filter({$0.newPhoto})
        let newImagesRaw = newTransfers.map({$0.image})
        guard let visit = visit, newImagesRaw.nonNilElementsMatchCount() else { return }
        let newImages = newImagesRaw.map({$0!})
        
        self.uploadImagesToAwsWithCompletion(orderedImages: newImages) { (orderedUrls) in
            let v = orderedUrls
        }
        
    }
    
}


