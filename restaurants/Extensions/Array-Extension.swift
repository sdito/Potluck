//
//  Array-Extension.swift
//  restaurants
//
//  Created by Steven Dito on 10/3/20.
//  Copyright © 2020 Steven Dito. All rights reserved.
//

import Foundation


extension Array {
    /// Optional, safe,  return value for element at idx
    func appAtIndex(_ idx: Int) -> Element? {
        if idx > self.count - 1 {
            return nil
        } else {
            return self[idx]
        }
    }
}
