//
//  DisposableTest.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import XCTest
import RxSwift
import RxTests

class DisposableTest : RxTest {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testActionDisposable() {
        var counter = 0
        
        let disposable = AnonymousDisposable {
            counter = counter + 1
        }
        
        XCTAssert(counter == 0)
        disposable.dispose()
        XCTAssert(counter == 1)
        disposable.dispose()
        XCTAssert(counter == 1)
    }
    
    func testHotObservable_Disposing() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(110, 1),
            next(180, 2),
            next(230, 3),
            next(270, 4),
            next(340, 5),
            next(380, 6),
            next(390, 7),
            next(450, 8),
            next(470, 9),
            next(560, 10),
            next(580, 11),
            completed(600)
            ])
        
        let res = scheduler.start(400) { () -> Observable<Int> in
            return xs.asObservable()
        }
        
        XCTAssertEqual(res.events, [
            next(230, 3),
            next(270, 4),
            next(340, 5),
            next(380, 6),
            next(390, 7),
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400)
            ])
    }
    
    func testCompositeDisposable_TestNormal() {
        var numberDisposed = 0
        let compositeDisposable = CompositeDisposable()
        
        let result1 = compositeDisposable.addDisposable(AnonymousDisposable {
            numberDisposed += 1
        })
        
        compositeDisposable.addDisposable(AnonymousDisposable {
            numberDisposed += 1
        })
        
        XCTAssertEqual(numberDisposed, 0)
        XCTAssertEqual(compositeDisposable.count, 2)
        XCTAssertTrue(result1 != nil)
        
        compositeDisposable.dispose()
        XCTAssertEqual(numberDisposed, 2)
        XCTAssertEqual(compositeDisposable.count, 0)
        
        let result = compositeDisposable.addDisposable(AnonymousDisposable {
            numberDisposed += 1
        })

        XCTAssertEqual(numberDisposed, 3)
        XCTAssertEqual(compositeDisposable.count, 0)
        XCTAssertTrue(result == nil)
    }
    
    func testCompositeDisposable_TestRemoving() {
        var numberDisposed = 0
        let compositeDisposable = CompositeDisposable()
        
        let result1 = compositeDisposable.addDisposable(AnonymousDisposable {
            numberDisposed += 1
            })
        
        let result2 = compositeDisposable.addDisposable(AnonymousDisposable {
            numberDisposed += 1
            })
        
        XCTAssertEqual(numberDisposed, 0)
        XCTAssertEqual(compositeDisposable.count, 2)
        XCTAssertTrue(result1 != nil)
        
        compositeDisposable.removeDisposable(result2!)

        XCTAssertEqual(numberDisposed, 1)
        XCTAssertEqual(compositeDisposable.count, 1)
     
        compositeDisposable.dispose()

        XCTAssertEqual(numberDisposed, 2)
        XCTAssertEqual(compositeDisposable.count, 0)
    }
    
    func testRefCountDisposable_RefCounting() {
        let d = BooleanDisposable()
        let r = RefCountDisposable(disposable: d)
        
        XCTAssertEqual(r.disposed, false)
        
        let d1 = r.retain()
        let d2 = r.retain()
        
        XCTAssertEqual(d.disposed, false)
        
        d1.dispose()
        XCTAssertEqual(d.disposed, false)
        
        d2.dispose()
        XCTAssertEqual(d.disposed, false)
        
        r.dispose()
        XCTAssertEqual(d.disposed, true)
        
        let d3 = r.retain()
        d3.dispose()
    }
    
    func testRefCountDisposable_PrimaryDisposesFirst() {
        let d = BooleanDisposable()
        let r = RefCountDisposable(disposable: d)
        
        XCTAssertEqual(r.disposed, false)
        
        let d1 = r.retain()
        let d2 = r.retain()
        
        XCTAssertEqual(d.disposed, false)
        
        d1.dispose()
        XCTAssertEqual(d.disposed, false)
        
        r.dispose()
        XCTAssertEqual(d.disposed, false)
        
        d2.dispose()
        XCTAssertEqual(d.disposed, true)
        
    }
}