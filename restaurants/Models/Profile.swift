//
//  Profile.swift
//  restaurants
//
//  Created by Steven Dito on 11/4/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import Foundation

struct Profile: Decodable {
    var account: Person
    var establishments: [Establishment]?
    var visits: [Visit]?
    var tags: [Tag]?
    var receivedRequestId: Int?
    var sentRequestId: Int?
    var isOwnProfile: Bool
    var friendshipId: Int?
    var nextVisitPageDate: String?
    
    var hasPendingReceivedRequest: Bool {
        return receivedRequestId != nil
    }
    
    var hasPendingSentRequest: Bool {
        return sentRequestId != nil
    }
    
    var areFriends: Bool {
        return friendshipId != nil
    }
    
    enum CodingKeys: String, CodingKey {
        case account
        case establishments
        case visits
        case tags
        case receivedRequestId = "received_request_from_user"
        case sentRequestId = "sent_request_to_user"
        case isOwnProfile = "is_own_profile"
        case friendshipId = "friend_id"
        case nextVisitPageDate = "visit_date_offset"
    }
}
