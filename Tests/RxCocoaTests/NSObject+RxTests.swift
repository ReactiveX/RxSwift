//
//  NSObject+RxTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 7/11/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxCocoa
import XCTest

import Foundation

final class NSObjectTests: RxTest {
    var a: NSObject!
}

// deallocated
extension NSObjectTests {
    func testDeallocated_ObservableFires() {
        a = NSObject()
        
        var fired = false
        
        _ = a.rx
            .deallocated
            .map { _ in
                return 1
            }
            .subscribe(onNext: { _ in
                fired = true
            })
        
        XCTAssertFalse(fired)
        
        a = NSObject()
        
        XCTAssertTrue(fired)
    }
    
    func testDeallocated_ObservableCompletes() {
        a = NSObject()
        
        var fired = false
        
        _ = a.rx
            .deallocated
            .map { _ in
                return 1
            }
            .subscribe(onCompleted: {
                fired = true
            })
        
        XCTAssertFalse(fired)
        
        a = NSObject()
        
        XCTAssertTrue(fired)
    }

    func testDeallocated_ObservableDispose() {
        a = NSObject()
        
        var fired = false

        _ = a.rx
            .deallocated
            .map { _ in
                return 1
            }
            .subscribe(onNext: { _ in
                fired = true
            })
            .dispose()

        XCTAssertFalse(fired)
        
        a = NSObject()
        
        XCTAssertFalse(fired)
    }
}

#if !DISABLE_SWIZZLING
// rx.deallocating
extension NSObjectTests {
    func testDeallocating_ObservableFires() {
        a = NSObject()
        
        var fired = false
        
        _ = a
            .rx.deallocating
            .map { _ in
                return 1
            }
            .subscribe(onNext: { _ in
                fired = true
            })
        
        XCTAssertFalse(fired)
        
        a = NSObject()
        
        XCTAssertTrue(fired)
    }
    
    func testDeallocating_ObservableCompletes() {
        a = NSObject()
        
        var fired = false
        
        _ = a
            .rx.deallocating
            .map { _ in
                return 1
            }
            .subscribe(onCompleted: {
                fired = true
            })
        
        XCTAssertFalse(fired)
        
        a = NSObject()
        
        XCTAssertTrue(fired)
    }
    
    func testDeallocating_ObservableDispose() {
        a = NSObject()
        
        var fired = false

        _ = a
            .rx.deallocating
            .map { _ in
                return 1
            }
            .subscribe(onNext: { _ in
                fired = true
            })
            .dispose()
        
        XCTAssertFalse(fired)
        
        a = NSObject()
        
        XCTAssertFalse(fired)
    }
}
#endif
