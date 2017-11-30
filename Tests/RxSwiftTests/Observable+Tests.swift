//
//  Observable+Tests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 7/24/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxCocoa
import RxTest
import XCTest

class ObservableTest : RxTest {
    
}

extension ObservableTest {
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

extension ObservableTest {
    func testAsObservable_asObservable() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(220, 2),
            completed(250)
        ])

        let ys = xs.asObservable()

        XCTAssert(xs !== ys)

        let res = scheduler.start { ys }

        let correct = [
            next(220, 2),
            completed(250)
        ]

        XCTAssertEqual(res.events, correct)
    }

    func testAsObservable_hides() {
        let xs = PrimitiveHotObservable<Int>()

        let res = xs.asObservable()

        XCTAssertTrue(res !== xs)
    }

    func testAsObservable_never() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs : Observable<Int> = Observable.never()

        let res = scheduler.start { xs }

        let correct: [Recorded<Event<Int>>] = []

        XCTAssertEqual(res.events, correct)
    }

    #if TRACE_RESOURCES
        func testAsObservableReleasesResourcesOnComplete() {
            _ = Observable<Int>.empty().asObservable().subscribe()
        }

        func testAsObservableReleasesResourcesOnError() {
            _ = Observable<Int>.empty().asObservable().subscribe()
        }
    #endif
}
