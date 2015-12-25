//
//  RxTest.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTests

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
    let event1: Event<Int> = .Error(lhs)
    let event2: Event<Int> = .Error(rhs)
    
    XCTAssertTrue(event1 == event2)
}

func XCTAssertEqualNSValues(lhs: AnyObject, rhs: AnyObject) {
    let pointerValuesAreEqual = (lhs as? NSValue)?.pointerValue == (rhs as? NSValue)?.pointerValue
    let areEqual = lhs.isEqual(rhs) || pointerValuesAreEqual

    XCTAssertTrue(areEqual)
    if !areEqual {
        print(lhs)
        print(rhs)
    }
}

func XCTAssertEqualAnyObjectArrayOfArrays(lhs: [[AnyObject]], _ rhs: [[AnyObject]]) {
    XCTAssertEqual(lhs, rhs) { lhs, rhs in
        if lhs.count != rhs.count {
            return false
        }

        return zip(lhs, rhs).reduce(true) { acc, n in
            let pointerValuesAreEqual: Bool
            if let firstPointer = (n.0 as? NSValue)?.pointerValue, secondPointer = (n.1 as? NSValue)?.pointerValue {
                pointerValuesAreEqual = firstPointer == secondPointer
            }
            else {
                pointerValuesAreEqual = false
            }
            let res = n.0.isEqual(n.1) || pointerValuesAreEqual
            return acc && res
        }
    }
}

func XCTAssertEqual<T>(lhs: [T], _ rhs: [T], _ comparison: (T, T) -> Bool) {
    XCTAssertEqual(lhs.count, rhs.count)
    let areEqual = zip(lhs, rhs).reduce(true) { (a: Bool, z: (T, T)) in a && comparison(z.0, z.1) }
    XCTAssertTrue(areEqual)
    if (!areEqual) {
        print(lhs)
        print(rhs)
    }
}

let testError = NSError(domain: "dummyError", code: -232, userInfo: nil)
let testError1 = NSError(domain: "dummyError1", code: -233, userInfo: nil)
let testError2 = NSError(domain: "dummyError2", code: -234, userInfo: nil)

func next<T>(value: T) -> Recorded<Event<T>> {
    return Recorded(time: 0, event: .Next(value))
}

func completed<T>() -> Recorded<Event<T>> {
    return Recorded(time: 0, event: .Completed)
}

func error<T>(error: ErrorType) -> Recorded<Event<T>> {
    return Recorded(time: 0, event: .Error(error))
}

func doOnBackgroundThread(action: () -> ()) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), action)
}

func doOnMainThread(action: () -> ()) {
    dispatch_async(dispatch_get_main_queue(), action)
}

class RxTest: XCTestCase {
    struct Defaults {
        static let created = 100
        static let subscribed = 200
        static let disposed = 1000
    }
    
    func sleep(time: NSTimeInterval) {
        NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate(timeIntervalSinceNow: time))
    }
    
    private var startResourceCount: Int32 = 0

    var accumulateStatistics: Bool {
        get {
            return true
        }
    }

#if TRACE_RESOURCES
    static var totalNumberOfAllocations: Int64 = 0
    static var totalNumberOfAllocatedBytes: Int64 = 0

    var startNumberOfAllocations: Int64 = 0
    var startNumberOfAllocatedBytes: Int64 = 0
#endif

    func setUpActions(){
        #if TRACE_RESOURCES
            self.startResourceCount = resourceCount
            registerMallocHooks()
            (startNumberOfAllocatedBytes, startNumberOfAllocations) = getMemoryInfo()
        #endif
    }

    #if os(Linux)
        func setUp() {
        setUpActions()
        }
    #else
        override func setUp() {
            setUpActions()
        }
    #endif

    func tearDownActions() {
        #if TRACE_RESOURCES
            // give 5 sec to clean up resources
            for var i = 0; i < 10; ++i {
                if self.startResourceCount < resourceCount {
                    // main schedulers need to finish work
                    NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate(timeIntervalSinceNow: 0.05))
                }
                else {
                    break
                }
            }

            XCTAssertEqual(self.startResourceCount, resourceCount)
            let (endNumberOfAllocatedBytes, endNumberOfAllocations) = getMemoryInfo()

            let (newBytes, newAllocations) = (endNumberOfAllocatedBytes - startNumberOfAllocatedBytes, endNumberOfAllocations - startNumberOfAllocations)

            if accumulateStatistics {
                RxTest.totalNumberOfAllocations += newAllocations
                RxTest.totalNumberOfAllocatedBytes += newBytes
            }
            print("allocatedBytes = \(newBytes), allocations = \(newAllocations) (totalBytes = \(RxTest.totalNumberOfAllocatedBytes), totalAllocations = \(RxTest.totalNumberOfAllocations))")
        #endif
    }

    #if os(Linux)
        func tearDown() {
            tearDownActions()
        }
    #else   
        override func tearDown() {
            // Put teardown code here. This method is called after the invocation of each test method in the class.
            super.tearDown()
            tearDownActions()
        }
    #endif
}
