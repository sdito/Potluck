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
    
    func itemsAtIndices(_ idxs: [Int]) -> [Element] {
        var items: [ArrayLiteralElement] = []
        for index in idxs {
            items.append(self[index])
        }
        return items
    }
    
}

protocol OptionalType {
    associatedtype W
    var optional: W? { get }
}

extension Optional: OptionalType {
    typealias W = Wrapped
    var optional: W? { return self }
}

extension Array where Element: OptionalType {
    func nonNilElementsMatchCount() -> Bool {
        var count = 0
        for element in self {
            if element.optional != nil {
                count += 1
            }
        }
        return count == self.count
    }
}
