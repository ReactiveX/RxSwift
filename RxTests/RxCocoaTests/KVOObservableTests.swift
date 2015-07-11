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

class Parent : NSObject {
    var disposeBag: DisposeBag! = DisposeBag()

    dynamic var val: String = ""
    
    init(callback: String? -> Void) {
        super.init()
        
        self.rx_observe("val", options: .Initial | .New, retainSelf: false)
            >- subscribeNext(callback)
            >- disposeBag.addDisposable
    }
    
    deinit {
        disposeBag = nil
    }
}

class Child : NSObject {
    let disposeBag = DisposeBag()
    
    init(parent: ParentWithChild, callback: String? -> Void) {
        super.init()
        parent.rx_observe("val", options: .Initial | .New, retainSelf: false)
            >- subscribeNext(callback)
            >- disposeBag.addDisposable
    }
    
    deinit {
        
    }
}

class ParentWithChild : NSObject {
    dynamic var val: String = ""
    
    var child: Child? = nil
    
    init(callback: String? -> Void) {
        super.init()
        child = Child(parent: self, callback: callback)
    }
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
        
        let os: Observable<String?> = testClass.rx_observe("pr", options: .Initial | .New)
        
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
    
    func test_ObserveAndDontRetainWorks() {
        var latest: String?
        var disposed = false
        
        var parent: Parent! = Parent { n in
            latest = n
        }
        
        parent.rx_deallocated
            >- subscribeCompleted {
                disposed = true
            }
        
        XCTAssertTrue(latest == "")
        XCTAssertTrue(disposed == false)
        
        parent.val = "1"
        
        XCTAssertTrue(latest == "1")
        XCTAssertTrue(disposed == false)
        
        parent = nil
        
        XCTAssertTrue(latest == "1")
        XCTAssertTrue(disposed == true)
    }
    
    func test_ObserveAndDontRetainWorks2() {
        var latest: String?
        var disposed = false
        
        var parent: ParentWithChild! = ParentWithChild { n in
            latest = n
        }
        
        parent.rx_deallocated
            >- subscribeCompleted {
                disposed = true
        }
        
        XCTAssertTrue(latest == "")
        XCTAssertTrue(disposed == false)
        
        parent.val = "1"
        
        XCTAssertTrue(latest == "1")
        XCTAssertTrue(disposed == false)
        
        parent = nil
        
        XCTAssertTrue(latest == "1")
        XCTAssertTrue(disposed == true)
    }
}