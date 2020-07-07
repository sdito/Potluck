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
}
