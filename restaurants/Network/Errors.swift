//
//  Errors.swift
//  restaurants
//
//  Created by Steven Dito on 8/16/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import Foundation


struct Errors {
    enum LogIn: Error {
        case unableToLogIn
        case unableToCreateAccount
        case emailInUse
        case usernameInUse
        case emailAndUsernameInUse
        case other
        
        var message: String {
            switch self {
            case .unableToLogIn:
                return "Either your password or email are incorrect. Please try again"
            case .unableToCreateAccount:
                return "Something went wrong trying to create an account. Please try again."
            case .other:
                return "Something went wrong. Please try again."
            case .emailInUse:
                return "Email is already in use. If you have already created an account, please log in instead of creating an account."
            case .usernameInUse:
                return "Username is already in use. Please try another username."
            case .emailAndUsernameInUse:
                return "Email and username are in use. If you have already created an account, please log in instead of creating an account."
            }
        }
    }
    
    enum YelpAddress: Error {
        case unableToConvertAddress(missing: [String], valuesFound: [String:String])
        case unableToFindYelpRestaurant
    }
    
}
