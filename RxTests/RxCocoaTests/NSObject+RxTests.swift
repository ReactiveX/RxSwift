//
//  NSObject+RxTests.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 7/11/15.
//
//

import Foundation
import RxSwift
import RxCocoa
import XCTest

class NSObjectTests: RxTest {
    func testDeallocObservableFires() {
        var a = NSObject()
        
        var fired = false
        
        a.rx_deallocated
            >- subscribeNext { _ in
                fired = true
            }
        
        XCTAssertFalse(fired)
        
        a = NSObject()
        
        XCTAssertTrue(fired)
    }
    
    func testDeallocObservableCompletes() {
        var a = NSObject()
        
        var fired = false
        
        a.rx_deallocated
            >- subscribeCompleted {
                fired = true
            }
        
        XCTAssertFalse(fired)
        
        a = NSObject()
        
        XCTAssertTrue(fired)
    }

    func testDeallocObservableDispose() {
        var a = NSObject()
        
        var fired = false
        
        a.rx_deallocated
            >- subscribeNext { _ in
                fired = true
            }
            >- scopedDispose
        
        XCTAssertFalse(fired)
        
        a = NSObject()
        
        XCTAssertFalse(fired)
    }
}