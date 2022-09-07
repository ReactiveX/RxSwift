//
//  Infallible+Tests.swift
//  Tests
//
//  Created by Shai Mishali on 11/20/20.
//  Copyright © 2020 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxCocoa
import RxRelay
import RxTest
import XCTest

class InfallibleTest: RxTest { }

extension InfallibleTest {
    func testAsInfallible_OnErrorJustReturn() {
        let scheduler = TestScheduler(initialClock: 0)
        let xs = scheduler.createHotObservable([
            .next(300, 9),
            .next(340, 13),
            .next(360, 111),
            .error(390, testError),
            .next(480, 320),
        ])

        let inf = xs.asInfallible(onErrorJustReturn: 600)
        let observer = scheduler.createObserver(Int.self)

        _ = inf.bind(to: observer)

        scheduler.start()

        XCTAssertEqual(observer.events, [
            .next(300, 9),
            .next(340, 13),
            .next(360, 111),
            .next(390, 600),
            .completed(390)
        ])
    }

    func testAsInfallible_OnErrorFallbackTo() {
        let scheduler = TestScheduler(initialClock: 0)
        let xs = scheduler.createHotObservable([
            .next(300, 9),
            .next(340, 13),
            .next(360, 111),
            .error(390, testError),
            .next(480, 320),
        ])

        let inf = xs.asInfallible(onErrorFallbackTo: Infallible<Int>.of(1, 2))
        let observer = scheduler.createObserver(Int.self)

        _ = inf.bind(to: observer)

        scheduler.start()

        XCTAssertEqual(observer.events, [
            .next(300, 9),
            .next(340, 13),
            .next(360, 111),
            .next(390, 1),
            .next(390, 2),
            .completed(390)
        ])
    }

    func testAsInfallible_OnErrorRecover() {
        let scheduler = TestScheduler(initialClock: 0)
        let xs = scheduler.createHotObservable([
            .next(300, 9),
            .next(340, 13),
            .next(360, 111),
            .error(390, testError),
            .next(480, 320),
        ])

        let ys = scheduler.createHotObservable([
            .next(500, 25),
            .next(600, 33),
            .completed(620)
        ])

        let inf = xs.asInfallible(onErrorRecover: { _ in ys.asInfallible(onErrorJustReturn: -1) })
        let observer = scheduler.createObserver(Int.self)

        _ = inf.bind(to: observer)

        scheduler.start()

        XCTAssertEqual(observer.events, [
            .next(300, 9),
            .next(340, 13),
            .next(360, 111),
            .next(500, 25),
            .next(600, 33),
            .completed(620)
        ])
    }
    
    func testAsInfallible_BehaviourRelay() {
        let scheduler = TestScheduler(initialClock: 0)
        let xs = BehaviorRelay<Int>(value: 0)
        
        let ys = scheduler.createHotObservable([
            .next(500, 25),
            .next(600, 33)
        ])

        let inf = xs.asInfallible()
        let observer = scheduler.createObserver(Int.self)

        _ = inf.bind(to: observer)
        _ = ys.bind(to: xs)

        scheduler.start()

        XCTAssertEqual(observer.events, [
            .next(0, 0),
            .next(500, 25),
            .next(600, 33)
        ])
    }
    
    func testAsInfallible_PublishRelay() {
        let scheduler = TestScheduler(initialClock: 0)
        let xs = PublishRelay<Int>()
        
        let ys = scheduler.createHotObservable([
            .next(500, 25),
            .next(600, 33)
        ])

        let inf = xs.asInfallible()
        let observer = scheduler.createObserver(Int.self)

        _ = inf.bind(to: observer)
        _ = ys.bind(to: xs)

        scheduler.start()

        XCTAssertEqual(observer.events, [
            .next(500, 25),
            .next(600, 33)
        ])
    }
    
    func testAsInfallible_ReplayRelay() {
        let scheduler = TestScheduler(initialClock: 0)
        let xs = ReplayRelay<Int>.create(bufferSize: 2)
        
        let ys = scheduler.createHotObservable([
            .next(500, 25),
            .next(600, 33)
        ])

        let inf = xs.asInfallible()
        let observer = scheduler.createObserver(Int.self)

        _ = inf.bind(to: observer)
        _ = ys.bind(to: xs)

        scheduler.start()

        XCTAssertEqual(observer.events, [
            .next(500, 25),
            .next(600, 33)
        ])
    }

    func testAnonymousInfallible_detachesOnDispose() {
        var observer: ((InfallibleEvent<Int>) -> Void)!
        let a = Infallible.create { o in
            observer = o
            return Disposables.create()
        } as Infallible<Int>

        var elements = [Int]()

        let d = a.subscribe(onNext: { n in
            elements.append(n)
        })

        XCTAssertEqual(elements, [])

        observer(.next(0))
        XCTAssertEqual(elements, [0])

        d.dispose()

        observer(.next(1))
        XCTAssertEqual(elements, [0])
    }

    func testAnonymousInfallible_detachesOnComplete() {
        var observer: ((InfallibleEvent<Int>) -> Void)!
        let a = Infallible.create { o in
            observer = o
            return Disposables.create()
        } as Infallible<Int>

        var elements = [Int]()

        _ = a.subscribe(onNext: { n in
            elements.append(n)
        })

        XCTAssertEqual(elements, [])

        observer(.next(0))
        XCTAssertEqual(elements, [0])

        observer(.completed)

        observer(.next(1))
        XCTAssertEqual(elements, [0])
    }
}

extension InfallibleTest {
    func testAsInfallible_never() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs: Infallible<Int> = Infallible.never()

        let res = scheduler.start { xs }

        let correct: [Recorded<Event<Int>>] = []

        XCTAssertEqual(res.events, correct)
    }

    #if TRACE_RESOURCES
        func testAsInfallibleReleasesResourcesOnComplete() {
            _ = Observable<Int>.empty().asInfallible(onErrorJustReturn: 0).subscribe()
        }

        func testAsInfallibleReleasesResourcesOnError() {
            _ = Observable<Int>.empty().asInfallible(onErrorJustReturn: 0).subscribe()
        }
    #endif
}

// MARK: - Subscribe with object
extension InfallibleTest {
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
        
        let inf = observable.asInfallible(onErrorJustReturn: -1)
        
        _ = inf
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
    
    func testSubscribeWithError() {
        var testObject: TestObject! = TestObject()
        let scheduler = TestScheduler(initialClock: 0)
        var values = [String]()
        var disposed: UUID?
        var completed: UUID?

        let observable = scheduler.createColdObservable([
            .next(10, 0),
            .next(20, 1),
            .error(30, testError),
            .next(40, 3),
        ])
        
        let inf = observable.asInfallible(onErrorJustReturn: -1)
        
        _ = inf
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
            uuid.uuidString + "-1"
        ])
        
        XCTAssertEqual(completed, uuid)
        XCTAssertEqual(disposed, uuid)
        
        XCTAssertNotNil(testObject)
        testObject = nil
        XCTAssertNil(testObject)
    }
}

private class TestObject: NSObject {
    var id = UUID()
}
