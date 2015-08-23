//
//  RxTest.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import CoreLocation

#if TRACE_RESOURCES
#elseif RELEASE
#else
//let a = unknown
#endif

// because otherwise OSX unit tests won't run
#if os(iOS)
    import UIKit
#elseif os(OSX)
    import AppKit
#endif

typealias Time = Int

func XCTAssertErrorEqual(lhs: ErrorType, _ rhs: ErrorType) {
    XCTAssertTrue(lhs as NSError === rhs as NSError)
}

let testError = NSError(domain: "dummyError", code: -232, userInfo: nil)
let testError1 = NSError(domain: "dummyError1", code: -233, userInfo: nil)
let testError2 = NSError(domain: "dummyError2", code: -234, userInfo: nil)

func next<T>(value: T) -> Recorded<T> {
    return Recorded(time: 0, event: .Next(value))
}

func completed<T>() -> Recorded<T> {
    return Recorded(time: 0, event: .Completed)
}

func error<T>(error: NSError) -> Recorded<T> {
    return Recorded(time: 0, event: .Error(error))
}

func next<T>(time: Time, _ value: T) -> Recorded<T> {
    return Recorded(time: time, event: .Next(value))
}

func completed<T>(time: Time) -> Recorded<T> {
    return Recorded(time: time, event: .Completed)
}

func error<T>(time: Time, _ error: NSError) -> Recorded<T> {
    return Recorded(time: time, event: .Error(error))
}

class RxTest: XCTestCase {
    struct Defaults {
        static let created = 100
        static let subscribed = 200
        static let disposed = 1000
    }
    
    func sleep(time: NSTimeInterval) {
       NSThread.sleepForTimeInterval(time)
    }
    
    private var startResourceCount: Int32 = 0
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
#if TRACE_RESOURCES
        self.startResourceCount = resourceCount
#endif
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()

#if TRACE_RESOURCES
        XCTAssertEqual(self.startResourceCount, resourceCount)
#endif
    }
    
    func on<T>(time: Time, _ event: Event<T>) -> Recorded<T> {
        return Recorded(time: time, event: event)
    }
    
}
