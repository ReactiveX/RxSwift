//
//  Recorded.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/14/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import Swift

struct Recorded<Element : Equatable> : CustomDebugStringConvertible, Equatable {
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
}

extension Recorded {
    var debugDescription: String {
        get {
            return "\(event) @ \(time)"
        }
    }
}

func == <T: Equatable>(lhs: Recorded<T>, rhs: Recorded<T>) -> Bool {
    return lhs.time == rhs.time && lhs.event == rhs.event
}


