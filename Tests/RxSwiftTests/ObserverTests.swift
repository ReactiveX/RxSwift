//
//  ObserverTests.swift
//  Tests
//
//  Created by Rob Cheung on 9/15/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObserverTests: RxTest { }

extension ObserverTests {

    func testConvenienceOn_Next() {
        var observer: AnyObserver<Int>!
        let a: Observable<Int> = Observable.create { o in
            observer = o
            return Disposables.create()
        }

        var elements = [Int]()

        let subscription = a.subscribe(onNext: { n in
            elements.append(n)
        })

        XCTAssertEqual(elements, [])

        observer.onNext(0)

        XCTAssertEqual(elements, [0])

        subscription.dispose()
    }

    func testConvenienceOn_Error() {
        var observer: AnyObserver<Int>!
        let a: Observable<Int> = Observable.create { o in
            observer = o
            return Disposables.create()
        }

        var elements = [Int]()
        var errorNotification: Swift.Error!

        _ = a.subscribe(
            onNext: { n in elements.append(n) },
            onError: { e in
                errorNotification = e
            }
        )

        XCTAssertEqual(elements, [])

        observer.onNext(0)
        XCTAssertEqual(elements, [0])

        observer.onError(testError)

        observer.onNext(1)
        XCTAssertEqual(elements, [0])
        XCTAssertErrorEqual(errorNotification, testError)
    }

    func testConvenienceOn_Complete() {
        var observer: AnyObserver<Int>!
        let a: Observable<Int> = Observable.create { o in
            observer = o
            return Disposables.create()
        }

        var elements = [Int]()

        _ = a.subscribe(onNext: { n in
            elements.append(n)
        })

        XCTAssertEqual(elements, [])

        observer.onNext(0)
        XCTAssertEqual(elements, [0])

        observer.onCompleted()

        observer.onNext(1)
        XCTAssertEqual(elements, [0])
    }
}

extension ObserverTests {
    func testMapElement() {
        let observer = PrimitiveMockObserver<Int>()

        observer.mapObserver { (x: Int) -> Int in
            return x / 2
        }.on(.next(2))

        XCTAssertEqual(observer.events, [next(1)])
    }

    func testMapElementCompleted() {
        let observer = PrimitiveMockObserver<Int>()

        observer.mapObserver { (x: Int) -> Int in
            return x / 2
        }.on(.completed)

        XCTAssertEqual(observer.events, [completed()])
    }

    func testMapElementError() {
        let observer = PrimitiveMockObserver<Int>()

        observer.mapObserver { (x: Int) -> Int in
            return x / 2
        }.on(.error(testError))

        XCTAssertEqual(observer.events, [error(testError)])
    }

    func testMapElementThrow() {
        let observer = PrimitiveMockObserver<Int>()

        observer.mapObserver { (x: Int) -> Int in
            throw testError
        }.on(.next(2))

        XCTAssertEqual(observer.events, [error(testError)])
    }
}
