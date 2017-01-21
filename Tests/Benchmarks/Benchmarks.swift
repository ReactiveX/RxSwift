//
//  Benchmarks.swift
//  Tests
//
//  Created by Krunoslav Zaher on 1/15/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa

let iterations = 10000

class Benchmarks: XCTestCase {
    
    override func setUp() {
    }

    override func tearDown() {
    }

    func testPublishSubjectPumping() {
        measure {
            var sum = 0
            let subject = PublishSubject<Int>()

            let subscription = subject
                .subscribe(onNext: { x in
                    sum += x
                })

            for _ in 0 ..< iterations * 100 {
                subject.on(.next(1))
            }

            subscription.dispose()

            XCTAssertEqual(sum, iterations * 100)
        }
    }

    func testPublishSubjectCreating() {
        measure {
            var sum = 0

            for _ in 0 ..< iterations * 10 {
                let subject = PublishSubject<Int>()

                let subscription = subject
                    .subscribe(onNext: { x in
                        sum += x
                    })

                for _ in 0 ..< 1 {
                    subject.on(.next(1))
                }

                subscription.dispose()
            }

            XCTAssertEqual(sum, iterations * 10)
        }
    }
    
    func testMapFilterPumping() {
        measure {
            var sum = 0
            let subscription = Observable<Int>.create { observer in
                for _ in 0 ..< iterations * 10 {
                    observer.on(.next(1))
                }
                return Disposables.create()
            }
                .map { $0 }.filter { _ in true }
                .map { $0 }.filter { _ in true }
                .map { $0 }.filter { _ in true }
                .map { $0 }.filter { _ in true }
                .map { $0 }.filter { _ in true }
                .map { $0 }.filter { _ in true }
                .subscribe(onNext: { x in
                    sum += x
                })

            subscription.dispose()
            
            XCTAssertEqual(sum, iterations * 10)
        }
    }

    func testMapFilterCreating() {
        measure {
            var sum = 0

            for _ in 0 ..< iterations {
                let subscription = Observable<Int>.create { observer in
                        for _ in 0 ..< 1 {
                            observer.on(.next(1))
                        }
                        return Disposables.create()
                    }
                    .map { $0 }.filter { _ in true }
                    .map { $0 }.filter { _ in true }
                    .map { $0 }.filter { _ in true }
                    .map { $0 }.filter { _ in true }
                    .map { $0 }.filter { _ in true }
                    .map { $0 }.filter { _ in true }
                    .subscribe(onNext: { x in
                        sum += x
                    })

                subscription.dispose()
            }

            XCTAssertEqual(sum, iterations)
        }
    }

    func testMapFilterDriverPumping() {
        measure {
            var sum = 0
            let subscription = Observable<Int>.create { observer in
                    for _ in 0 ..< iterations * 10 {
                        observer.on(.next(1))
                    }
                    return Disposables.create()
                }.asDriver(onErrorJustReturn: -1)
                .map { $0 }.filter { _ in true }
                .map { $0 }.filter { _ in true }
                .map { $0 }.filter { _ in true }
                .map { $0 }.filter { _ in true }
                .map { $0 }.filter { _ in true }
                .map { $0 }.filter { _ in true }
                .drive(onNext: { x in
                    sum += x
                })

            subscription.dispose()

            XCTAssertEqual(sum, iterations * 10)
        }
    }

    func testMapFilterDriverCreating() {
        measure {
            var sum = 0

            for _ in 0 ..< iterations {
                let subscription = Observable<Int>.create { observer in
                        for _ in 0 ..< 1 {
                            observer.on(.next(1))
                        }
                        return Disposables.create()
                    }.asDriver(onErrorJustReturn: -1)
                    .map { $0 }.filter { _ in true }
                    .map { $0 }.filter { _ in true }
                    .map { $0 }.filter { _ in true }
                    .map { $0 }.filter { _ in true }
                    .map { $0 }.filter { _ in true }
                    .map { $0 }.filter { _ in true }
                    .drive(onNext: { x in
                        sum += x
                    })

                subscription.dispose()
            }

            XCTAssertEqual(sum, iterations)
        }
    }

    func testFlatMapsPumping() {
        measure {
            var sum = 0
            let subscription = Observable<Int>.create { observer in
                    for _ in 0 ..< iterations * 10 {
                        observer.on(.next(1))
                    }
                    return Disposables.create()
                }
                .flatMap { x in Observable.just(x) }
                .flatMap { x in Observable.just(x) }
                .flatMap { x in Observable.just(x) }
                .flatMap { x in Observable.just(x) }
                .flatMap { x in Observable.just(x) }
                .subscribe(onNext: { x in
                    sum += x
                })

            subscription.dispose()

            XCTAssertEqual(sum, iterations * 10)
        }
    }

    func testFlatMapsCreating() {
        measure {
            var sum = 0
            for _ in 0 ..< iterations {
                let subscription = Observable<Int>.create { observer in
                    for _ in 0 ..< 1 {
                        observer.on(.next(1))
                    }
                    return Disposables.create()
                }
                .flatMap { x in Observable.just(x) }
                .flatMap { x in Observable.just(x) }
                .flatMap { x in Observable.just(x) }
                .flatMap { x in Observable.just(x) }
                .flatMap { x in Observable.just(x) }
                .subscribe(onNext: { x in
                    sum += x
                })

            subscription.dispose()
            }

            XCTAssertEqual(sum, iterations)
        }
    }

    func testFlatMapLatestPumping() {
        measure {
            var sum = 0
            let subscription = Observable<Int>.create { observer in
                for _ in 0 ..< iterations * 10 {
                    observer.on(.next(1))
                }
                return Disposables.create()
                }
                .flatMapLatest { x in Observable.just(x) }
                .flatMapLatest { x in Observable.just(x) }
                .flatMapLatest { x in Observable.just(x) }
                .flatMapLatest { x in Observable.just(x) }
                .flatMapLatest { x in Observable.just(x) }
                .subscribe(onNext: { x in
                    sum += x
                })

            subscription.dispose()

            XCTAssertEqual(sum, iterations * 10)
        }
    }

    func testFlatMapLatestCreating() {
        measure {
            var sum = 0
            for _ in 0 ..< iterations {
                let subscription = Observable<Int>.create { observer in
                    for _ in 0 ..< 1 {
                        observer.on(.next(1))
                    }
                    return Disposables.create()
                    }
                    .flatMapLatest { x in Observable.just(x) }
                    .flatMapLatest { x in Observable.just(x) }
                    .flatMapLatest { x in Observable.just(x) }
                    .flatMapLatest { x in Observable.just(x) }
                    .flatMapLatest { x in Observable.just(x) }
                    .subscribe(onNext: { x in
                        sum += x
                    })

                subscription.dispose()
            }
            
            XCTAssertEqual(sum, iterations)
        }
    }

    func testCombineLatestPumping() {
        measure {
            var sum = 0
            var last = Observable.combineLatest(
                Observable.just(1), Observable.just(1), Observable.just(1),
                    Observable<Int>.create { observer in
                    for _ in 0 ..< iterations * 10 {
                        observer.on(.next(1))
                    }
                    return Disposables.create()
                }) { x, _, _ ,_ in x }

            for _ in 0 ..< 6 {
                last = Observable.combineLatest(Observable.just(1), Observable.just(1), Observable.just(1), last) { x, _, _ ,_ in x }
            }
            
            let subscription = last
                .subscribe(onNext: { x in
                    sum += x
                })

            subscription.dispose()

            XCTAssertEqual(sum, iterations * 10)
        }
    }

    func testCombineLatestCreating() {
        measure {
            var sum = 0
            for _ in 0 ..< iterations {
                var last = Observable.combineLatest(
                    Observable<Int>.create { observer in
                        for _ in 0 ..< 1 {
                            observer.on(.next(1))
                        }
                        return Disposables.create()
                }, Observable.just(1), Observable.just(1), Observable.just(1)) { x, _, _ ,_ in x }

                for _ in 0 ..< 6 {
                    last = Observable.combineLatest(last, Observable.just(1), Observable.just(1), Observable.just(1)) { x, _, _ ,_ in x }
                }

                let subscription = last
                    .subscribe(onNext: { x in
                        sum += x
                    })
                
                subscription.dispose()
            }

            XCTAssertEqual(sum, iterations)
        }
    }
}
