//
//  PreSignedPost.swift
//  restaurants
//
//  Created by Steven Dito on 12/18/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

struct PreSignedPost: Decodable {
    let url: String
    let fields: [String:String]
    
    var fileName: String {
        return fields["key"]!
    }
    
    func uploadImage(image: UIImage, completion: @escaping (Bool) -> Void, progressUpdated: ((Double) -> Void)? = nil) {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else { completion(false); return }
        
        let req = AF.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in fields {
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
            // needs to be ordered with the imageData last
            multipartFormData.append(imageData, withName: "file")
            
        }, to: url)
        
        req.response { (done) in
            guard let statusCode = done.response?.statusCode, (200...299) ~= statusCode else {
                completion(false)
                return
            }
            completion(true)
        }.uploadProgress { (progress) in
            progressUpdated?(progress.fractionCompleted)
        }
    }
}
