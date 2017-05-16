//
//  Observable+SubscriptionTest.swift
//  Tests
//
//  Created by Krunoslav Zaher on 10/13/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import XCTest

class ObservableSubscriptionTests : RxTest {
    func testSubscribeOnNext() {
        let publishSubject = PublishSubject<Int>()

        var onNextCalled = 0
        var onErrorCalled = 0
        var onCompletedCalled = 0
        var onDisposedCalled = 0

        var lastElement: Int? = nil
        var lastError: Swift.Error? = nil

        let subscription = publishSubject.subscribe(onNext: { n in
                lastElement = n
                onNextCalled += 1
            }, onError: { e in
                lastError = e
                onErrorCalled += 1
            }, onCompleted: {
                onCompletedCalled += 1
            }, onDisposed: {
                onDisposedCalled += 1
            })

        XCTAssertTrue(lastElement == nil)
        XCTAssertTrue(lastError == nil)
        XCTAssertTrue(onNextCalled == 0)
        XCTAssertTrue(onErrorCalled == 0)
        XCTAssertTrue(onCompletedCalled == 0)
        XCTAssertTrue(onDisposedCalled == 0)

        publishSubject.on(.next(1))

        XCTAssertTrue(lastElement == 1)
        XCTAssertTrue(lastError == nil)
        XCTAssertTrue(onNextCalled == 1)
        XCTAssertTrue(onErrorCalled == 0)
        XCTAssertTrue(onCompletedCalled == 0)
        XCTAssertTrue(onDisposedCalled == 0)

        subscription.dispose()
        publishSubject.on(.next(2))

        XCTAssertTrue(lastElement == 1)
        XCTAssertTrue(lastError == nil)
        XCTAssertTrue(onNextCalled == 1)
        XCTAssertTrue(onErrorCalled == 0)
        XCTAssertTrue(onCompletedCalled == 0)
        XCTAssertTrue(onDisposedCalled == 1)
    }

    func testSubscribeOnError() {
        let publishSubject = PublishSubject<Int>()

        var onNextCalled = 0
        var onErrorCalled = 0
        var onCompletedCalled = 0
        var onDisposedCalled = 0

        var lastElement: Int? = nil
        var lastError: Swift.Error? = nil

        let subscription = publishSubject.subscribe(onNext: { n in
                lastElement = n
                onNextCalled += 1
            }, onError: { e in
                lastError = e
                onErrorCalled += 1
            }, onCompleted: {
                onCompletedCalled += 1
            }, onDisposed: {
                onDisposedCalled += 1
            })

        XCTAssertTrue(lastElement == nil)
        XCTAssertTrue(lastError == nil)
        XCTAssertTrue(onNextCalled == 0)
        XCTAssertTrue(onErrorCalled == 0)
        XCTAssertTrue(onCompletedCalled == 0)
        XCTAssertTrue(onDisposedCalled == 0)

        publishSubject.on(.error(testError))

        XCTAssertTrue(lastElement == nil)
        XCTAssertTrue((lastError as! TestError) == testError)
        XCTAssertTrue(onNextCalled == 0)
        XCTAssertTrue(onErrorCalled == 1)
        XCTAssertTrue(onCompletedCalled == 0)
        XCTAssertTrue(onDisposedCalled == 1)

        subscription.dispose()
        publishSubject.on(.next(2))
        publishSubject.on(.completed)

        XCTAssertTrue(lastElement == nil)
        XCTAssertTrue((lastError as! TestError) == testError)
        XCTAssertTrue(onNextCalled == 0)
        XCTAssertTrue(onErrorCalled == 1)
        XCTAssertTrue(onCompletedCalled == 0)
        XCTAssertTrue(onDisposedCalled == 1)
    }

    func testSubscribeOnCompleted() {
        let publishSubject = PublishSubject<Int>()

        var onNextCalled = 0
        var onErrorCalled = 0
        var onCompletedCalled = 0
        var onDisposedCalled = 0

        var lastElement: Int? = nil
        var lastError: Swift.Error? = nil

        let subscription = publishSubject.subscribe(onNext: { n in
            lastElement = n
            onNextCalled += 1
            }, onError: { e in
                lastError = e
                onErrorCalled += 1
            }, onCompleted: {
                onCompletedCalled += 1
            }, onDisposed: {
                onDisposedCalled += 1
        })

        XCTAssertTrue(lastElement == nil)
        XCTAssertTrue(lastError == nil)
        XCTAssertTrue(onNextCalled == 0)
        XCTAssertTrue(onErrorCalled == 0)
        XCTAssertTrue(onCompletedCalled == 0)
        XCTAssertTrue(onDisposedCalled == 0)

        publishSubject.on(.completed)

        XCTAssertTrue(lastElement == nil)
        XCTAssertTrue(lastError == nil)
        XCTAssertTrue(onNextCalled == 0)
        XCTAssertTrue(onErrorCalled == 0)
        XCTAssertTrue(onCompletedCalled == 1)
        XCTAssertTrue(onDisposedCalled == 1)

        subscription.dispose()
        publishSubject.on(.next(2))
        publishSubject.on(.error(testError))

        XCTAssertTrue(lastElement == nil)
        XCTAssertTrue(lastError == nil)
        XCTAssertTrue(onNextCalled == 0)
        XCTAssertTrue(onErrorCalled == 0)
        XCTAssertTrue(onCompletedCalled == 1)
        XCTAssertTrue(onDisposedCalled == 1)
    }

    func testDisposed() {
        let publishSubject = PublishSubject<Int>()

        var onNextCalled = 0
        var onErrorCalled = 0
        var onCompletedCalled = 0
        var onDisposedCalled = 0

        var lastElement: Int? = nil
        var lastError: Swift.Error? = nil

        let subscription = publishSubject.subscribe(onNext: { n in
            lastElement = n
            onNextCalled += 1
            }, onError: { e in
                lastError = e
                onErrorCalled += 1
            }, onCompleted: {
                onCompletedCalled += 1
            }, onDisposed: {
                onDisposedCalled += 1
        })

        XCTAssertTrue(lastElement == nil)
        XCTAssertTrue(lastError == nil)
        XCTAssertTrue(onNextCalled == 0)
        XCTAssertTrue(onErrorCalled == 0)
        XCTAssertTrue(onCompletedCalled == 0)
        XCTAssertTrue(onDisposedCalled == 0)

        publishSubject.on(.next(1))
        subscription.dispose()
        publishSubject.on(.next(2))
        publishSubject.on(.error(testError))
        publishSubject.on(.completed)

        XCTAssertTrue(lastElement == 1)
        XCTAssertTrue(lastError == nil)
        XCTAssertTrue(onNextCalled == 1)
        XCTAssertTrue(onErrorCalled == 0)
        XCTAssertTrue(onCompletedCalled == 0)
        XCTAssertTrue(onDisposedCalled == 1)
    }
}
