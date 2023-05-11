//
//  Infallible+CombineLatestTests+arity.swift
//  Tests
//
//  Created by Hal Lee on 5/11/23.
//  Copyright © 2023 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class InfallibleCombineLatestTest: RxTest {

    func testCombineLatest_Arity() {
        let scheduler = TestScheduler(initialClock: 0)
        let firstStream = scheduler.createColdObservable([
            .next(1, 1)
        ]).asInfallible(onErrorFallbackTo: .never())

        let secondStream = scheduler.createColdObservable([
            .next(1, 1)
        ]).asInfallible(onErrorFallbackTo: .never())

        let observer = scheduler.start(created: 0, subscribed: 0, disposed: 100) {
            return Infallible
                .combineLatest(firstStream, secondStream)
                .map { $0 + $1 }
        }

        XCTAssertEqual(observer.events, [
            .next(1, 2),
        ])
    }

    func testCombineLatest_3_Arity() {
        let scheduler = TestScheduler(initialClock: 0)
        let firstStream = scheduler.createColdObservable([
            .next(1, 1)
        ]).asInfallible(onErrorFallbackTo: .never())

        let secondStream = scheduler.createColdObservable([
            .next(1, 1)
        ]).asInfallible(onErrorFallbackTo: .never())

        let thirdStream = scheduler.createColdObservable([
            .next(1, 1)
        ]).asInfallible(onErrorFallbackTo: .never())

        let observer = scheduler.start(created: 0, subscribed: 0, disposed: 100) {
            return Infallible
                .combineLatest(firstStream, secondStream, thirdStream)
                .map { $0 + $1 + $2 }
        }

        XCTAssertEqual(observer.events, [
            .next(1, 3),
        ])
    }

    func testCombineLatest_4_Arity() {
        let scheduler = TestScheduler(initialClock: 0)
        let firstStream = scheduler.createColdObservable([
            .next(1, 1)
        ]).asInfallible(onErrorFallbackTo: .never())

        let secondStream = scheduler.createColdObservable([
            .next(1, 1)
        ]).asInfallible(onErrorFallbackTo: .never())

        let thirdStream = scheduler.createColdObservable([
            .next(1, 1)
        ]).asInfallible(onErrorFallbackTo: .never())

        let fourthStream = scheduler.createColdObservable([
            .next(1, 1)
        ]).asInfallible(onErrorFallbackTo: .never())

        let observer = scheduler.start(created: 0, subscribed: 0, disposed: 100) {
            return Infallible
                .combineLatest(firstStream, secondStream, thirdStream, fourthStream)
                .map { (a: Int, b: Int, c: Int, d: Int) -> Int in a + b + c + d }
        }

        XCTAssertEqual(observer.events, [
            .next(1, 4),
        ])
    }

    func testCombineLatest_5_Arity() {
        let scheduler = TestScheduler(initialClock: 0)
        let firstStream = scheduler.createColdObservable([
            .next(1, 1)
        ]).asInfallible(onErrorFallbackTo: .never())

        let secondStream = scheduler.createColdObservable([
            .next(1, 1)
        ]).asInfallible(onErrorFallbackTo: .never())

        let thirdStream = scheduler.createColdObservable([
            .next(1, 1)
        ]).asInfallible(onErrorFallbackTo: .never())

        let fourthStream = scheduler.createColdObservable([
            .next(1, 1)
        ]).asInfallible(onErrorFallbackTo: .never())

        let fifthStream = scheduler.createColdObservable([
            .next(1, 1)
        ]).asInfallible(onErrorFallbackTo: .never())

        let observer = scheduler.start(created: 0, subscribed: 0, disposed: 100) {
            return Infallible
                .combineLatest(firstStream, secondStream, thirdStream, fourthStream, fifthStream)
                .map { (a: Int, b: Int, c: Int, d: Int, e: Int) -> Int in a + b + c + d + e }
        }

        XCTAssertEqual(observer.events, [
            .next(1, 5),
        ])
    }

    func testCombineLatest_6_Arity() {
        let scheduler = TestScheduler(initialClock: 0)
        let firstStream = scheduler.createColdObservable([
            .next(1, 1)
        ]).asInfallible(onErrorFallbackTo: .never())

        let secondStream = scheduler.createColdObservable([
            .next(1, 1)
        ]).asInfallible(onErrorFallbackTo: .never())

        let thirdStream = scheduler.createColdObservable([
            .next(1, 1)
        ]).asInfallible(onErrorFallbackTo: .never())

        let fourthStream = scheduler.createColdObservable([
            .next(1, 1)
        ]).asInfallible(onErrorFallbackTo: .never())

        let fifthStream = scheduler.createColdObservable([
            .next(1, 1)
        ]).asInfallible(onErrorFallbackTo: .never())

        let sixthStream = scheduler.createColdObservable([
            .next(1, 1)
        ]).asInfallible(onErrorFallbackTo: .never())

        let observer = scheduler.start(created: 0, subscribed: 0, disposed: 100) {
            return Infallible
                .combineLatest(firstStream, secondStream, thirdStream, fourthStream, fifthStream, sixthStream)
                .map { (a: Int, b: Int, c: Int, d: Int, e: Int, f: Int) -> Int in a + b + c + d + e + f }
        }

        XCTAssertEqual(observer.events, [
            .next(1, 6),
        ])
    }

    func testCombineLatest_7_Arity() {
        let scheduler = TestScheduler(initialClock: 0)
        let firstStream = scheduler.createColdObservable([
            .next(1, 1)
        ]).asInfallible(onErrorFallbackTo: .never())

        let secondStream = scheduler.createColdObservable([
            .next(1, 1)
        ]).asInfallible(onErrorFallbackTo: .never())

        let thirdStream = scheduler.createColdObservable([
            .next(1, 1)
        ]).asInfallible(onErrorFallbackTo: .never())

        let fourthStream = scheduler.createColdObservable([
            .next(1, 1)
        ]).asInfallible(onErrorFallbackTo: .never())

        let fifthStream = scheduler.createColdObservable([
            .next(1, 1)
        ]).asInfallible(onErrorFallbackTo: .never())

        let sixthStream = scheduler.createColdObservable([
            .next(1, 1)
        ]).asInfallible(onErrorFallbackTo: .never())

        let seventhStream = scheduler.createColdObservable([
            .next(1, 1)
        ]).asInfallible(onErrorFallbackTo: .never())

        let observer = scheduler.start(created: 0, subscribed: 0, disposed: 100) {
            return Infallible
                .combineLatest(firstStream, secondStream, thirdStream, fourthStream, fifthStream, sixthStream, seventhStream)
                .map { (a: Int, b: Int, c: Int, d: Int, e: Int, f: Int, g: Int) -> Int in a + b + c + d + e + f + g }
        }

        XCTAssertEqual(observer.events, [
            .next(1, 7),
        ])
    }

    func testCombineLatest_8_Arity() {
        let scheduler = TestScheduler(initialClock: 0)
        let firstStream = scheduler.createColdObservable([
            .next(1, 1)
        ]).asInfallible(onErrorFallbackTo: .never())

        let secondStream = scheduler.createColdObservable([
            .next(1, 1)
        ]).asInfallible(onErrorFallbackTo: .never())

        let thirdStream = scheduler.createColdObservable([
            .next(1, 1)
        ]).asInfallible(onErrorFallbackTo: .never())

        let fourthStream = scheduler.createColdObservable([
            .next(1, 1)
        ]).asInfallible(onErrorFallbackTo: .never())

        let fifthStream = scheduler.createColdObservable([
            .next(1, 1)
        ]).asInfallible(onErrorFallbackTo: .never())

        let sixthStream = scheduler.createColdObservable([
            .next(1, 1)
        ]).asInfallible(onErrorFallbackTo: .never())

        let seventhStream = scheduler.createColdObservable([
            .next(1, 1)
        ]).asInfallible(onErrorFallbackTo: .never())

        let eighthStream = scheduler.createColdObservable([
            .next(1, 1)
        ]).asInfallible(onErrorFallbackTo: .never())

        let observer = scheduler.start(created: 0, subscribed: 0, disposed: 100) {
            return Infallible
                .combineLatest(firstStream, secondStream, thirdStream, fourthStream, fifthStream, sixthStream, seventhStream, eighthStream)
                .map { (a: Int, b: Int, c: Int, d: Int, e: Int, f: Int, g: Int, h: Int) -> Int in a + b + c + d + e + f + g + h }
        }

        XCTAssertEqual(observer.events, [
            .next(1, 8),
        ])
    }

}
