//
//  RxTests.swift
//  Rx
//
//  Created by Krunoslav Zaher on 12/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import XCTest

public typealias Time = Int

/**
These methods are conceptually extensions of `XCTestCase` but because referencing them in closures would
require specifying `self.*`, they are made global.
*/
//extension XCTestCase {
    /**
    Factory method for an `.Next` event recorded at a given time with a given value.
     
     - parameter time: Recorded virtual time the `.Next` event occurs.
     - parameter element: Next sequence element.
     - returns: Recorded event in time.
    */
    public func next<T>(time: Time, _ element: T) -> Recorded<T> {
        return Recorded(time: time, event: .Next(element))
    }

    /**
    Factory method for an `.Completed` event recorded at a given time.
     
     - parameter time: Recorded virtual time the `.Completed` event occurs.
     - parameter type: Sequence elements type.
     - returns: Recorded event in time.
    */
    public func completed<T>(time: Time, _ type: T.Type = T.self) -> Recorded<T> {
        return Recorded(time: time, event: .Completed)
    }

    /**
    Factory method for an `.Error` event recorded at a given time with a given error.
     
     - parameter time: Recorded virtual time the `.Completed` event occurs.
    */
    public func error<T>(time: Time, _ error: ErrorType, _ type: T.Type = T.self) -> Recorded<T> {
        return Recorded(time: time, event: .Error(error))
    }
//}