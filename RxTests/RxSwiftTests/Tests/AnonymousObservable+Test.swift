//
//  AnonymousObservable+Test.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 7/24/15.
//
//

import Foundation
import RxSwift
import XCTest

class AnonymousObservableTests : RxTest {
    
}

extension AnonymousObservableTests {
    func testAnonymousObservable_detachesOnDispose() {
        var observer: ObserverOf<Int>!
        let a = create { o in
            observer = o
            return NopDisposable.instance
        } as Observable<Int>
        
        var elements = [Int]()
        
        let d = a >- subscribeNext { n in
            elements.append(n)
        }
        
        XCTAssertEqual(elements, [])
        
        sendNext(observer, 0)
        XCTAssertEqual(elements, [0])
        
        d.dispose()

        sendNext(observer, 1)
        XCTAssertEqual(elements, [0])
    }
    
    func testAnonymousObservable_detachesOnComplete() {
        var observer: ObserverOf<Int>!
        let a = create { o in
            observer = o
            return NopDisposable.instance
        } as Observable<Int>
        
        var elements = [Int]()
        
        let d = a >- subscribeNext { n in
            elements.append(n)
        }
        
        XCTAssertEqual(elements, [])
        
        sendNext(observer, 0)
        XCTAssertEqual(elements, [0])
        
        sendCompleted(observer)
        
        sendNext(observer, 1)
        XCTAssertEqual(elements, [0])
    }

    func testAnonymousObservable_detachesOnError() {
        var observer: ObserverOf<Int>!
        let a = create { o in
            observer = o
            return NopDisposable.instance
        } as Observable<Int>
        
        var elements = [Int]()
        
        let d = a >- subscribeNext { n in
            elements.append(n)
        }
        
        XCTAssertEqual(elements, [])
        
        sendNext(observer, 0)
        XCTAssertEqual(elements, [0])
        
        sendError(observer, testError)
        
        sendNext(observer, 1)
        XCTAssertEqual(elements, [0])
    }
}