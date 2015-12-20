//
//  ObserverTests.swift
//  RxTests
//
//  Created by Rob Cheung on 9/15/15.
//
//

import XCTest
import RxSwift

class ObserverTests: RxTest { }

extension ObserverTests {

    func testConvenienceOn_Next() {
        var observer: AnyObserver<Int>!
        let a: Observable<Int> = create { o in
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
        let a: Observable<Int> = create { o in
            observer = o
            return NopDisposable.instance
        }

        var elements = [Int]()
        var errrorNotification: NSError!

        _ = a.subscribe(
            onNext: { n in elements.append(n) },
            onError: { e in
                errrorNotification = e as NSError
            }
        )

        XCTAssertEqual(elements, [])

        observer.onNext(0)
        XCTAssertEqual(elements, [0])

        observer.onError(testError)

        observer.onNext(1)
        XCTAssertEqual(elements, [0])
        XCTAssertEqual(errrorNotification, testError)
    }

    func testConvenienceOn_Complete() {
        var observer: AnyObserver<Int>!
        let a: Observable<Int> = create { o in
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
