//
//  Benchmarks.swift
//  Tests
//
//  Created by Krunoslav Zaher on 1/15/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift

let iterations = 10000

class Benchmarks: XCTestCase {
    
    override func setUp() {
    }

    override func tearDown() {
    }

    func testPublishSubjectPumping() {
        measure {
            var sum = 0
            let subject = Subject<Int, Never, Never>.makePublishSubject()

            let subscription = subject
                .subscribe(onNext: { x in
                    sum += x
                })

            for _ in 0 ..< iterations * 100 {
                subject.observer(.next(1))
            }

            subscription.dispose()

            XCTAssertEqual(sum, iterations * 100)
        }
    }

    func testPublishSubjectPumpingTwoSubscriptions() {
        measure {
            var sum = 0
            let subject = Subject<Int, Never, Never>.makePublishSubject()

            let subscription1 = subject
                .subscribe(onNext: { x in
                    sum += x
                })

            let subscription2 = subject
                .subscribe(onNext: { x in
                    sum += x
                })

            for _ in 0 ..< iterations * 100 {
                subject.observer(.next(1))
            }

            subscription1.dispose()
            subscription2.dispose()

            XCTAssertEqual(sum, iterations * 100 * 2)
        }
    }

    func testPublishSubjectCreating() {
        measure {
            var sum = 0

            for _ in 0 ..< iterations * 10 {
                let subject = Subject<Int, Never, Never>.makePublishSubject()

                let subscription = subject
                    .subscribe(onNext: { x in
                        sum += x
                    })

                for _ in 0 ..< 1 {
                    subject.observer(.next(1))
                }

                subscription.dispose()
            }

            XCTAssertEqual(sum, iterations * 10)
        }
    }
    
    func testMapFilterPumping() {
        measure {
            var sum = 0
            let subscription = ObservableSource<Int, Never, Never> { observer in
                for _ in 0 ..< iterations * 10 {
                    observer(.next(1))
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
                let subscription = ObservableSource<Int, Never, Never> { observer in
                        for _ in 0 ..< 1 {
                            observer(.next(1))
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
            let subscription = ObservableSource<Int, Never, Never> { observer in
                    for _ in 0 ..< iterations * 10 {
                        observer(.next(1))
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
                let subscription = ObservableSource<Int, Never, Never> { observer in
                        for _ in 0 ..< 1 {
                            observer(.next(1))
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
            let subscription = ObservableSource<Int, (), Never> { observer in
                    for _ in 0 ..< iterations * 10 {
                        observer(.next(1))
                    }
                    return Disposables.create()
                }
                .flatMap { x in ObservableSource.just(x) }
                .flatMap { x in ObservableSource.just(x) }
                .flatMap { x in ObservableSource.just(x) }
                .flatMap { x in ObservableSource.just(x) }
                .flatMap { x in ObservableSource.just(x) }
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
                let subscription = ObservableSource<Int, (), Never> { observer in
                    for _ in 0 ..< 1 {
                        observer(.next(1))
                    }
                    return Disposables.create()
                }
                .flatMap { x in ObservableSource.just(x) }
                .flatMap { x in ObservableSource.just(x) }
                .flatMap { x in ObservableSource.just(x) }
                .flatMap { x in ObservableSource.just(x) }
                .flatMap { x in ObservableSource.just(x) }
                .subscribe(onNext: { x in
                    sum += x
                })

            subscription.dispose()
            }

            XCTAssertEqual(sum, iterations)
        }
    }

//    func testFlatMapLatestPumping() {
//        measure {
//            var sum = 0
//            let subscription = ObservableSource<Int, (), Never> { observer in
//                for _ in 0 ..< iterations * 10 {
//                    observer(.next(1))
//                }
//                return Disposables.create()
//                }
//                .flatMapLatest { x in ObservableSource.just(x) }
//                .flatMapLatest { x in ObservableSource.just(x) }
//                .flatMapLatest { x in ObservableSource.just(x) }
//                .flatMapLatest { x in ObservableSource.just(x) }
//                .flatMapLatest { x in ObservableSource.just(x) }
//                .subscribe(onNext: { x in
//                    sum += x
//                })
//
//            subscription.dispose()
//
//            XCTAssertEqual(sum, iterations * 10)
//        }
//    }
//
//    func testFlatMapLatestCreating() {
//        measure {
//            var sum = 0
//            for _ in 0 ..< iterations {
//                let subscription = ObservableSource<Int, (), Never> { observer in
//                    for _ in 0 ..< 1 {
//                        observer(.next(1))
//                    }
//                    return Disposables.create()
//                    }
//                    .flatMapLatest { x in ObservableSource.just(x) }
//                    .flatMapLatest { x in ObservableSource.just(x) }
//                    .flatMapLatest { x in ObservableSource.just(x) }
//                    .flatMapLatest { x in ObservableSource.just(x) }
//                    .flatMapLatest { x in ObservableSource.just(x) }
//                    .subscribe(onNext: { x in
//                        sum += x
//                    })
//
//                subscription.dispose()
//            }
//            
//            XCTAssertEqual(sum, iterations)
//        }
//    }

    func testCombineLatestPumping() {
        measure {
            var sum = 0
            var last = ObservableSource<Int, (), Never>.combineLatest(
                ObservableSource.just(1), ObservableSource.just(1), ObservableSource.just(1),
                    ObservableSource<Int, (), Never> { observer in
                    for _ in 0 ..< iterations * 10 {
                        observer(.next(1))
                    }
                    return Disposables.create()
                }) { x, _, _ ,_ in x }

            for _ in 0 ..< 6 {
                last = ObservableSource.combineLatest(ObservableSource.just(1), ObservableSource.just(1), ObservableSource.just(1), last) { x, _, _ ,_ in x }
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
                var last = ObservableSource<Int, (), Never>.combineLatest(
                    ObservableSource<Int, (), Never> { observer in
                        for _ in 0 ..< 1 {
                            observer(.next(1))
                        }
                        return Disposables.create()
                }, ObservableSource.just(1), ObservableSource.just(1), ObservableSource.just(1)) { x, _, _ ,_ in x }

                for _ in 0 ..< 6 {
                    last = ObservableSource.combineLatest(last, ObservableSource.just(1), ObservableSource.just(1), ObservableSource.just(1)) { x, _, _ ,_ in x }
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
