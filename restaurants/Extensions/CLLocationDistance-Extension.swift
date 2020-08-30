//
//  CLLocationDistance-Extension.swift
//  restaurants
//
//  Created by Steven Dito on 8/27/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import CoreLocation


extension CLLocationDistance {
    func convertMetersToMiles() -> String {
        let distance = (Measurement(value: self, unit: UnitLength.meters).converted(to: UnitLength.miles).value * 10).rounded() / 10.0
        if distance <= 0.09 {
            return "Right there"
        } else {
            return "\(distance) miles away"
        }
    }
}
