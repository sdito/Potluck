//
//  Int-Extension.swift
//  restaurants
//
//  Created by Steven Dito on 11/12/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import Foundation

extension Int {
    var s: String {
        if self == 1 {
            return ""
        } else {
            return "s"
        }
    }
}
