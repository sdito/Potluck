//
//  TimeInterval-Extension.swift
//  restaurants
//
//  Created by Steven Dito on 7/8/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import Foundation


extension TimeInterval {
    static let minute: TimeInterval = 60.0
    static let hour: TimeInterval = .minute * 60.0
    static let day: TimeInterval = .hour * 24.0
    
    func displayForSmallerTimes() -> String {
        if self > .day {
            return "Long drive"
        } else if self < .hour {
            // less than an hour, get the minutes
            let minutes = Int(self / .minute)
            return "\(minutes) minute drive"
        } else {
            // combo of hours and minutes
            let hours = Int(self / .hour)
            let remainder = Int(self) % Int(.hour)
            let minutes = remainder / Int(.minute)
            return "\(hours) h \(minutes) min drive"
        }
    }
}
