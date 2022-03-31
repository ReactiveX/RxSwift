//
//  Signal+ConcurrencyTests.swift
//  RxCocoa
//
//  Created by Jinwoo Kim on 3/31/22.
//  Copyright © 2022 Krunoslav Zaher. All rights reserved.
//

#if swift(>=5.5.2) && canImport(_Concurrency) && !os(Linux)
import Dispatch
import RxSwift
import RxCocoa
import XCTest
import RxTest

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
class SignalConcurrencyTests: RxTest {
    let scheduler = TestScheduler(initialClock: 0)
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension SignalConcurrencyTests {
    @MainActor func testSignalEmitsElementFromAwait() async {
        let signal = Signal.from({
            "Hello"
        }, onErrorJustReturn: nil)
        
        var didLoop = false
        
        for await value in signal.values {
            XCTAssertEqual(value, "Hello")
            didLoop = true
        }
        
        XCTAssertTrue(didLoop)
    }
}

#endif
