//
//  NotificationName.swift
//  restaurants
//
//  Created by Steven Dito on 9/4/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import Foundation


extension Notification.Name {
    static let userLoggedOut = Notification.Name("com.stevendito.userLoggedOut")
    static let userLoggedIn = Notification.Name("com.stevendito.userLoggedIn")
    static let establishmentDeleted = Notification.Name("com.stevendito.establishmentDeleted")
    static let establishmentUpdated = Notification.Name("com.stevendito.establishmentUpdated")
}
