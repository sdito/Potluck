//
//  Date-Extension.swift
//  restaurants
//
//  Created by Steven Dito on 7/6/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import Foundation


extension Date {
    static func convertYelpStringDate(_ str: String) -> Date? {
        // 2016-09-28 08:55:29 is an example
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.dateFormat = "yyyy-MM-dd HH-mm:ss"  // yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from: str)
        return date
    }
    
    func getDisplayTime() -> String {
        let interval = Calendar.current.dateComponents([.year, .month, .day], from: self, to: Date())
        if let year = interval.year, year > 0 {
            return year == 1 ? "\(year)" + " " + "year ago" :
                "\(year)" + " " + "years ago"
        } else if let month = interval.month, month > 0 {
            return month == 1 ? "\(month)" + " " + "month ago" :
                "\(month)" + " " + "months ago"
        } else if let day = interval.day, day > 0 {
            return day == 1 ? "\(day)" + " " + "day ago" :
                "\(day)" + " " + "days ago"
        } else {
            return "a moment ago"

        }
    }
}
