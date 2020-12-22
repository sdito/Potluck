//
//  ImageTransfer.swift
//  restaurants
//
//  Created by Steven Dito on 12/20/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import Foundation
import UIKit

class ImageTransfer {
    
    init(previousMain: Bool, newMain: Bool, newPhoto: Bool, image: UIImage?, previousOrder: Int?, newOrder: Int?) {
        self.previousMain = previousMain
        self.newMain = newMain
        self.newPhoto = newPhoto
        self.image = image
        self.previousOrder = previousOrder
        self.newOrder = newOrder
    }
    
    var previousMain: Bool
    var newMain: Bool
    var newPhoto: Bool
    var image: UIImage?
    var previousOrder: Int?
    var newOrder: Int?
    var newUploadedToFile: String?
    
    
    struct ImageTransferEncode: Encodable {
        let previous_main: Bool
        let new_main: Bool
        let new_photo: Bool
        let previous_order: Int?
        let new_order: Int?
        let new_uploaded_to_file: String?
        
        init(_ transfer: ImageTransfer) {
            self.previous_main = transfer.previousMain
            self.new_main = transfer.newMain
            self.new_photo = transfer.newPhoto
            self.previous_order = transfer.previousOrder
            self.new_order = transfer.newOrder
            self.new_uploaded_to_file = transfer.newUploadedToFile
        }
    }
    
    static func toParams(encoder: JSONEncoder, transfers: [ImageTransfer]) throws -> [[String:Any]] {
        let encodable = transfers.map({ImageTransferEncode($0)})
        let data = try encoder.encode(encodable)
        let object = try JSONSerialization.jsonObject(with: data)
        guard let json = object as? [[String: Any]] else {
            let context = DecodingError.Context(codingPath: [], debugDescription: "Deserialized object is not a dictionary")
            throw DecodingError.typeMismatch(type(of: object), context)
        }
        return json
    }
    
}
