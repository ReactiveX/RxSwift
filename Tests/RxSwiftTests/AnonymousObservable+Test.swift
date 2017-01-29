//
//  AnonymousObservable+Test.swift
//  Tests
//
//  Created by Krunoslav Zaher on 7/24/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxCocoa
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

    #if !os(Linux)
    func testAnonymousObservable_disposeReferenceDoesntRetainObservable() {

        var targetDeallocated = false

        var target: NSObject? = NSObject()
        
        let subscription = { () -> Disposable in
            return autoreleasepool {
                let localTarget = target!

                let sequence = Observable.create { _ in
                    return Disposables.create {
                        if arc4random_uniform(4) == 0 {
                            print(localTarget)
                        }
                    }
                }.map { (n: Int) -> Int in
                    if arc4random_uniform(4) == 0 {
                        print(localTarget)
                    }
                    return n
                }

                let subscription = sequence.subscribe(onNext: { _ in })

                _ = localTarget.rx.deallocated.subscribe(onNext: { _ in
                    targetDeallocated = true
                })

                return subscription
            }
        }()

        target = nil
        
        XCTAssertFalse(targetDeallocated)
        subscription.dispose()
        XCTAssertTrue(targetDeallocated)
    }
    #endif
}
