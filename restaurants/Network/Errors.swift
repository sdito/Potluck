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
        case other
    }
}
