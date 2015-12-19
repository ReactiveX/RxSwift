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

public struct Recorded<Element> : CustomDebugStringConvertible {
    public let time: Time
    public let event: Event<Element>
    
    public init(time: Time, event: Event<Element>) {
        self.time = time
        self.event = event
    }
    
    public var value: Element {
        get {
            guard case .Next(let element) = event else {
                fatalError("Requesting value for non event")
            }

            return element
        }
    }
}

extension Recorded {
    public var debugDescription: String {
        get {
            return "\(event) @ \(time)"
        }
    }
}

func == <T: Equatable>(lhs: Recorded<T>, rhs: Recorded<T>) -> Bool {
    return lhs.time == rhs.time && lhs.event == rhs.event
}