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
    
}

// rx_deallocated
extension NSObjectTests {
    func testDeallocated_ObservableFires() {
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
    
    func testDeallocated_ObservableCompletes() {
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

    func testDeallocated_ObservableDispose() {
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

// rx_deallocating
extension NSObjectTests {
    func testDeallocating_ObservableFires() {
        var a = NSObject()
        
        var fired = false
        
        a.rx_deallocating
            >- subscribeNext { _ in
                fired = true
        }
        
        XCTAssertFalse(fired)
        
        a = NSObject()
        
        XCTAssertTrue(fired)
    }
    
    func testDeallocating_ObservableCompletes() {
        var a = NSObject()
        
        var fired = false
        
        a.rx_deallocating
            >- subscribeCompleted {
                fired = true
        }
        
        XCTAssertFalse(fired)
        
        a = NSObject()
        
        XCTAssertTrue(fired)
    }
    
    func testDeallocating_ObservableDispose() {
        var a = NSObject()
        
        var fired = false
        
        a.rx_deallocating
            >- subscribeNext { _ in
                fired = true
            }
            >- scopedDispose
        
        XCTAssertFalse(fired)
        
        a = NSObject()
        
        XCTAssertFalse(fired)
    }
}