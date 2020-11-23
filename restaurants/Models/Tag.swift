//
//  Tag.swift
//  restaurants
//
//  Created by Steven Dito on 11/4/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import Foundation

struct Tag: Codable, Equatable {
    var display: String
    var alias: String?
    var id: Int?
    var firstUsed: Date?
    var lastUsed: Date?
    var numberOfVisits: Int?
    
    init(display: String, alias: String? = nil) {
        self.display = display
        self.alias = alias
    }
    
    enum CodingKeys: String, CodingKey {
        case display
        case alias
        case id
        case firstUsed = "first_used"
        case lastUsed = "last_used"
        case numberOfVisits = "number_of_visits"
    }
    
    struct TagDecoder: Decodable {
        var tags: [Tag]
    }
    
}
