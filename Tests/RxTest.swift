//
//  RxTest.swift
//  Tests
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

import struct Foundation.TimeInterval
import struct Foundation.Date

import class Foundation.RunLoop

#if os(Linux)
    import Foundation
#endif

#if TRACE_RESOURCES
#elseif RELEASE
#elseif os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
#elseif os(Linux)
#else
let failure = unhandled_case()
#endif

// because otherwise macOS unit tests won't run
#if os(iOS)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif



#if os(Linux)
// TODO: Implement PerformanceTests.swift for Linux
func getMemoryInfo() -> (bytes: Int64, allocations: Int64) {
    return (0, 0)
}
#endif


class RxTest
    : XCTestCase {

#if TRACE_RESOURCES
    fileprivate var startResourceCount: Int32 = 0
#endif

    var accumulateStatistics: Bool {
        return true
    }

    #if TRACE_RESOURCES
        static var totalNumberOfAllocations: Int64 = 0
        static var totalNumberOfAllocatedBytes: Int64 = 0

        var startNumberOfAllocations: Int64 = 0
        var startNumberOfAllocatedBytes: Int64 = 0
    #endif

    override func setUp() {
        super.setUp()
        setUpActions()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        tearDownActions()
    }
}

extension RxTest {
    struct Defaults {
        static let created = 100
        static let subscribed = 200
        static let disposed = 1000
    }

    func sleep(_ time: TimeInterval) {
        Thread.sleep(forTimeInterval: time)
    }

    func setUpActions(){
        _ = Hooks.defaultErrorHandler // lazy load resource so resource count matches
        _ = Hooks.customCaptureSubscriptionCallstack // lazy load resource so resource count matches
        #if TRACE_RESOURCES
            self.startResourceCount = Resources.total
            //registerMallocHooks()
            (startNumberOfAllocatedBytes, startNumberOfAllocations) = getMemoryInfo()
        #endif
    }

    func tearDownActions() {
        #if TRACE_RESOURCES
            // give 5 sec to clean up resources
            for _ in 0..<30 {
                if self.startResourceCount < Resources.total {
                    // main schedulers need to finish work
                    print("Waiting for resource cleanup ...")
                    let mode = RunLoop.Mode.default

                    RunLoop.current.run(mode: mode, before: Date(timeIntervalSinceNow: 0.05))
                }
                else {
                    break
                }
            }

            XCTAssertEqual(self.startResourceCount, Resources.total)
            let (endNumberOfAllocatedBytes, endNumberOfAllocations) = getMemoryInfo()

            let (newBytes, newAllocations) = (endNumberOfAllocatedBytes - startNumberOfAllocatedBytes, endNumberOfAllocations - startNumberOfAllocations)

            if accumulateStatistics {
                RxTest.totalNumberOfAllocations += newAllocations
                RxTest.totalNumberOfAllocatedBytes += newBytes
            }
            print("allocatedBytes = \(newBytes), allocations = \(newAllocations) (totalBytes = \(RxTest.totalNumberOfAllocatedBytes), totalAllocations = \(RxTest.totalNumberOfAllocations))")
        #endif
    }
}
