//
//  Tag.swift
//  restaurants
//
//  Created by Steven Dito on 11/4/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import Foundation

struct Tag: Codable {
    var display: String
    var alias: String?
    var id: Int?
    var firstUsed: Date?
    var lastUsed: Date?
    
    init(display: String) {
        self.display = display
    }
    
    enum CodingKeys: String, CodingKey {
        case display
        case alias
        case id
        case firstUsed = "first_used"
        case lastUsed = "last_used"
    }
    
}