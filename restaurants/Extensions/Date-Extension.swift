//
//  Date-Extension.swift
//  restaurants
//
//  Created by Steven Dito on 7/6/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import Foundation


extension Date {
    
    func dateString(style: DateFormatter.Style = .medium) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar.current
        dateFormatter.dateStyle = style
        return dateFormatter.string(from: self)
    }
    
    func convertFromUTC() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
    /*
     
    Apple
       Sunday - 1
       Monday - 2
       Tuesday - 3
       Wednesday - 4
       Thursday - 5
       Friday - 6
       Saturday - 7
    
    Yelp
       Sunday - 6
       Monday - 0
       Tuesday - 1
       Wednesday - 2
       Thursday - 3
       Friday - 4
       Saturday - 5
     
    */
    
    static func convertWeekdayFromYelpToStandard(yelpDate: Int) -> Restaurant.SystemTime.Weekday {
        let dict: [Int:Restaurant.SystemTime.Weekday] = [
        /* Sunday */     6: .sunday,
        /* Monday */     0: .monday,
        /* Tuesday */    1: .tuesday,
        /* Wednesday */  2: .wednesday,
        /* Thursday */   3: .thursday,
        /* Friday */     4: .friday,
        /* Saturday */   5: .saturday,
        ]
        return dict[yelpDate]!
    }
    
    static func convertWeekdayFromAppleToStandard(appleDate: Int) -> Restaurant.SystemTime.Weekday {
        let dict: [Int:Restaurant.SystemTime.Weekday] = [
        /* Sunday */     1: .sunday,
        /* Monday */     2: .monday,
        /* Tuesday */    3: .tuesday,
        /* Wednesday */  4: .wednesday,
        /* Thursday */   5: .thursday,
        /* Friday */     6: .friday,
        /* Saturday */   7: .saturday,
        ]
        return dict[appleDate]!
    }
    
    func getFourDigitTimeValue() -> Int {
        let calendar = Calendar.current
        var hour = String(calendar.component(.hour, from: self))
        var minutes = String(calendar.component(.minute, from: self))
        
        if hour.count == 1 {
            hour = "0\(hour)"
        }
        
        if minutes.count == 1 {
            minutes = "0\(minutes)"
        }
        
        let combined = Int("\(hour)\(minutes)")!
        return combined
    }
    
    static func getDayOfWeek() -> Int {
        let day = Calendar.current.component(.weekday, from: Date())
        return day
    }
    
    static func getWeekday() -> Restaurant.SystemTime.Weekday {
        let dayOfWeek = Date.getDayOfWeek()
        let value = Date.convertWeekdayFromAppleToStandard(appleDate: dayOfWeek)
        return value
    }
    
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
