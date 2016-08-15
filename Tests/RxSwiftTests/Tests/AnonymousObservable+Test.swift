//
//  AnonymousObservable+Test.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 7/24/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import XCTest

class AnonymousObservableTests : RxTest {
    
}

extension AnonymousObservableTests {
    func testAnonymousObservable_detachesOnDispose() {
        var observer: AnyObserver<Int>!
        let a = Observable.create { o in
            observer = o
            return Disposables.create()
        } as Observable<Int>
        
        var elements = [Int]()
        
        let d = a.subscribe(onNext: { n in
            elements.append(n)
        })
        
        XCTAssertEqual(elements, [])
        
        observer.on(.next(0))
        XCTAssertEqual(elements, [0])
        
        d.dispose()

        observer.on(.next(1))
        XCTAssertEqual(elements, [0])
    }
    
    func testAnonymousObservable_detachesOnComplete() {
        var observer: AnyObserver<Int>!
        let a = Observable.create { o in
            observer = o
            return Disposables.create()
        } as Observable<Int>
        
        var elements = [Int]()
        
        _ = a.subscribe(onNext: { n in
            elements.append(n)
        })

        XCTAssertEqual(elements, [])
        
        observer.on(.next(0))
        XCTAssertEqual(elements, [0])
        
        observer.on(.completed)
        
        observer.on(.next(1))
        XCTAssertEqual(elements, [0])
    }

    func testAnonymousObservable_detachesOnError() {
        var observer: AnyObserver<Int>!
        let a = Observable.create { o in
            observer = o
            return Disposables.create()
        } as Observable<Int>
        
        var elements = [Int]()

        _ = a.subscribe(onNext: { n in
            elements.append(n)
        })

        XCTAssertEqual(elements, [])
        
        observer.on(.next(0))
        XCTAssertEqual(elements, [0])
        
        observer.on(.error(testError))
        
        observer.on(.next(1))
        XCTAssertEqual(elements, [0])
    }
}
