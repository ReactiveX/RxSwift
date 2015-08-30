//
//  Recorded.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/14/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

struct Recorded<Element : Equatable> : CustomStringConvertible, Equatable {
    let time: Time
    let event: Event<Element>
    
    init(time: Time, event: Event<Element>) {
        self.time = time
        self.event = event
    }
    
    var value: Element {
        get {
            switch self.event {
            case .Next(let value):
                return value
            default:
                assert(false)
                let element: Element! = nil
                return element!
            }
        }
    }
    
    var description: String {
        get {
            return "\(event) @ \(time)"
        }
    }
}

func == <T: Equatable>(lhs: Recorded<T>, rhs: Recorded<T>) -> Bool {
    return lhs.time == rhs.time && lhs.event == rhs.event
}


// workaround for swift compiler bug
struct EquatableArray<Element: Equatable> : Equatable {
    let elements: [Element]
    init(_ elements: [Element]) {
        self.elements = elements
    }
}

func == <E: Equatable>(lhs: EquatableArray<E>, rhs: EquatableArray<E>) -> Bool {
    return lhs.elements == rhs.elements
}