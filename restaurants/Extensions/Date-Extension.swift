//
//  Date-Extension.swift
//  restaurants
//
//  Created by Steven Dito on 7/6/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import Foundation


extension Date {
    
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
    
    static func convertWeekdayFromYelpToApple(yelpDate: Int) -> Int {
        let dict: [Int:Int] = [
        /* Sunday */     6: 1,
        /* Monday */     0: 2,
        /* Tuesday */    1: 3,
        /* Wednesday */  2: 4,
        /* Thursday */   3: 5,
        /* Friday */     4: 6,
        /* Saturday */   5: 7,
        ]
        return dict[yelpDate]!
    }
    
    static func convertWeekdayFromAppleToYelp(appleDate: Int) -> Int {
        let dict: [Int:Int] = [
        /* Sunday */     1: 6,
        /* Monday */     2: 0,
        /* Tuesday */    3: 1,
        /* Wednesday */  4: 2,
        /* Thursday */   5: 3,
        /* Friday */     6: 4,
        /* Saturday */   7: 5,
        ]
        return dict[appleDate]!
    }
    
    
    static func getDayOfWeek() -> Int {
        let day = Calendar.current.component(.weekday, from: Date())
        return day
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
