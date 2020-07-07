//
//  Review.swift
//  restaurants
//
//  Created by Steven Dito on 7/6/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import Foundation


struct Review {
    var id: String
    var rating: Int
    var profileURL: String
    var imageURL: String
    var reviewerName: String
    var text: String
    var timeCreated: Date?
    var url: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case rating
        case userContainer = "user"
        case profileURL = "profile_url"
        case imageURL = "image_url"
        case reviewerName = "name"
        case text
        case timeCreated = "time_created"
        case url
    }
}


extension Review: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let user = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .userContainer)
        
        id = try container.decode(String.self, forKey: .id)
        rating = try container.decode(Int.self, forKey: .rating)
        profileURL = try user.decode(String.self, forKey: .profileURL)
        imageURL = try user.decode(String.self, forKey: .imageURL)
        reviewerName = try user.decode(String.self, forKey: .reviewerName)
        text = try container.decode(String.self, forKey: .text)
        
        timeCreated = Date.convertYelpStringDate(try container.decode(String.self, forKey: .timeCreated))
        url = try container.decode(String.self, forKey: .url)
        
    }
}
