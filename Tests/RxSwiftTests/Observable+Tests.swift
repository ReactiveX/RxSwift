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

class ObservableTest: RxTest { }

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
            .next(150, 1),
            .next(220, 2),
            .completed(250)
        ])

        let ys = xs.asObservable()

        XCTAssert(xs !== ys)

        let res = scheduler.start { ys }

        let correct = Recorded.events(
            .next(220, 2),
            .completed(250)
        )

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

// MARK: - Subscribe with object
extension ObservableTest {
    func testSubscribeWithNext() {
        var testObject: TestObject! = TestObject()
        let scheduler = TestScheduler(initialClock: 0)
        var values = [String]()
        var disposed: UUID?
        var completed: UUID?

        let observable = scheduler.createColdObservable([
            .next(10, 0),
            .next(20, 1),
            .next(30, 2),
            .next(40, 3),
            .completed(50)
        ])
        
        _ = observable
            .subscribe(
                with: testObject,
                onNext: { object, value in values.append(object.id.uuidString + "\(value)") },
                onCompleted: { completed = $0.id },
                onDisposed: { disposed = $0.id }
            )
        
        scheduler.start()
        
        let uuid = testObject.id
        XCTAssertEqual(values, [
            uuid.uuidString + "0",
            uuid.uuidString + "1",
            uuid.uuidString + "2",
            uuid.uuidString + "3"
        ])
        
        XCTAssertEqual(completed, uuid)
        XCTAssertEqual(disposed, uuid)
        
        XCTAssertNotNil(testObject)
        testObject = nil
        XCTAssertNil(testObject)
    }
}

// MARK: - Deferred
private class DeferredExpectation {
    let expectation: XCTestExpectation

    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }

    func bar() -> Observable<Void> {
        Observable<Void>
            .deferred {
                self.expectation.fulfill()
                return .never()
            }
    }
}

extension ObservableTest {
    func testDeferredFactoryClosureLifetime() {
        let factoryClosureInvoked = expectation(description: "Factory closure has been invoked")
        var foo: DeferredExpectation? = DeferredExpectation(expectation: factoryClosureInvoked)
        weak var initialFoo = foo

        let disposable = foo?.bar().subscribe()

        wait(for: [factoryClosureInvoked])

        // reset foo to let the initial instance deallocate
        foo = nil

        // we know that the factory closure has already been executed,
        // and the foo reference has been nilled, so there should be nothing
        // keeping the object alive
        XCTAssertNil(initialFoo)

        disposable?.dispose()
    }

    func testObservableFactoryClosureLifetime() {
        class Foo {
            let expectation: XCTestExpectation

            init(expectation: XCTestExpectation) {
                self.expectation = expectation
            }

            func bar() -> Observable<Void> {
                Observable<Void>
                    .create { _ in
                        self.expectation.fulfill()
                        return Disposables.create()
                    }
            }
        }

        let factoryClosureInvoked = expectation(description: "Factory closure has been invoked")
        var foo: Foo? = Foo(expectation: factoryClosureInvoked)
        weak var initialFoo = foo

        let disposable = foo?.bar().subscribe()

        wait(for: [factoryClosureInvoked])

        // reset foo to let the initial instance deallocate
        foo = nil

        XCTAssertNil(initialFoo)

        disposable?.dispose()
    }
}

private class TestObject: NSObject {
    var id = UUID()
}
