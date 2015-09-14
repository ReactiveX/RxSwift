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
        
        let d = a.subscribeNext { n in
            elements.append(n)
        }
        
        XCTAssertEqual(elements, [])
        
        observer.on(.Next(0))
        XCTAssertEqual(elements, [0])
        
        d.dispose()

        observer.on(.Next(1))
        XCTAssertEqual(elements, [0])
    }
    
    func testAnonymousObservable_detachesOnComplete() {
        var observer: ObserverOf<Int>!
        let a = create { o in
            observer = o
            return NopDisposable.instance
        } as Observable<Int>
        
        var elements = [Int]()
        
        let d = a.subscribeNext { n in
            elements.append(n)
        }
        
        XCTAssertEqual(elements, [])
        
        observer.on(.Next(0))
        XCTAssertEqual(elements, [0])
        
        observer.on(.Completed)
        
        observer.on(.Next(1))
        XCTAssertEqual(elements, [0])
    }

    func testAnonymousObservable_detachesOnError() {
        var observer: ObserverOf<Int>!
        let a = create { o in
            observer = o
            return NopDisposable.instance
        } as Observable<Int>
        
        var elements = [Int]()
        
        let d = a.subscribeNext { n in
            elements.append(n)
        }
        
        XCTAssertEqual(elements, [])
        
        observer.on(.Next(0))
        XCTAssertEqual(elements, [0])
        
        observer.on(.Error(testError))
        
        observer.on(.Next(1))
        XCTAssertEqual(elements, [0])
    }
}