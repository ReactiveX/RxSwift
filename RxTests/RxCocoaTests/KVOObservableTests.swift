//
//  KVOObservableTests.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 5/19/15.
//
//

import Foundation
import XCTest
import RxSwift
import RxCocoa

class TestClass : NSObject {
    dynamic var pr: String? = "0"
}

class KVOObservableTests : RxTest {
    func test_New() {
        let testClass = TestClass()
        
        let os: Observable<String?> = testClass.rx_observe("pr", options: .New)
        
        var latest: String?
        
        var _d: ScopedDispose! = os >- subscribeNext { latest = $0 } >- scopedDispose
        
        XCTAssertTrue(latest == nil)
        
        testClass.pr = "1"
        
        XCTAssertEqual(latest!, "1")
        
        testClass.pr = "2"
        
        XCTAssertEqual(latest!, "2")

        testClass.pr = nil
        
        XCTAssertTrue(latest == nil)

        testClass.pr = "3"
        
        XCTAssertEqual(latest!, "3")
        
        _d = nil
        
        testClass.pr = "4"

        XCTAssertEqual(latest!, "3")
    }
    
    func test_New_And_Initial() {
        let testClass = TestClass()
        
        let os: Observable<String?> = testClass.rx_observe("pr", options: .Initial)
        
        var latest: String?
        
        var _d: ScopedDispose! = os >- subscribeNext { latest = $0 } >- scopedDispose
        
        XCTAssertTrue(latest == "0")
        
        testClass.pr = "1"
        
        XCTAssertEqual(latest!, "1")
        
        testClass.pr = "2"
        
        XCTAssertEqual(latest!, "2")
        
        testClass.pr = nil
        
        XCTAssertTrue(latest == nil)
        
        testClass.pr = "3"
        
        XCTAssertEqual(latest!, "3")
        
        _d = nil
        
        testClass.pr = "4"
        
        XCTAssertEqual(latest!, "3")
    }
    
    func test_Default() {
        let testClass = TestClass()
        
        let os: Observable<String?> = testClass.rx_observe("pr")
        
        var latest: String?
        
        var _d: ScopedDispose! = os >- subscribeNext { latest = $0 } >- scopedDispose
        
        XCTAssertTrue(latest == "0")
        
        testClass.pr = "1"
        
        XCTAssertEqual(latest!, "1")
        
        testClass.pr = "2"
        
        XCTAssertEqual(latest!, "2")
        
        testClass.pr = nil
        
        XCTAssertTrue(latest == nil)
        
        testClass.pr = "3"
        
        XCTAssertEqual(latest!, "3")
        
        _d = nil
        
        testClass.pr = "4"
        
        XCTAssertEqual(latest!, "3")
    }
}