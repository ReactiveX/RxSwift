//
//  ObserverTests.swift
//  RxTests
//
//  Created by Rob Cheung on 9/15/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import XCTest
import RxSwift

class ObserverTests: RxTest { }

extension ObserverTests {

    func testConvenienceOn_Next() {
        var observer: AnyObserver<Int>!
        let a: Observable<Int> = Observable.create { o in
            observer = o
            return NopDisposable.instance
        }

        var elements = [Int]()

        _ = a.subscribeNext { n in
            elements.append(n)
        }

        XCTAssertEqual(elements, [])

        observer.onNext(0)

        XCTAssertEqual(elements, [0])
    }

    func testConvenienceOn_Error() {
        var observer: AnyObserver<Int>!
        let a: Observable<Int> = Observable.create { o in
            observer = o
            return NopDisposable.instance
        }

        var elements = [Int]()
        var errorNotification: ErrorType!

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
            return NopDisposable.instance
        }

        var elements = [Int]()

        _ = a.subscribeNext { n in
            elements.append(n)
        }

        XCTAssertEqual(elements, [])

        observer.onNext(0)
        XCTAssertEqual(elements, [0])

        observer.onCompleted()

        observer.onNext(1)
        XCTAssertEqual(elements, [0])
    }
}
