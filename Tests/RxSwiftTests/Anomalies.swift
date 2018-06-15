//
//  Anomalies.swift
//  Tests
//
//  Created by Krunoslav Zaher on 10/22/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxCocoa
import RxTest
import XCTest
import Dispatch

import class Foundation.Thread

/**
 Makes sure github anomalies and edge cases don't surface up again.
 */
class AnomaliesTest: RxTest {
}

extension AnomaliesTest {
    func test936() {
        func performSharingOperatorsTest(share: @escaping (Observable<Int>) -> Observable<Int>) {
            let queue = DispatchQueue(
                label: "Test",
                attributes: .concurrent // commenting this to use a serial queue remove the issue
            )

            for i in 0 ..< 10 {
                let expectation = self.expectation(description: "wait until sequence completes")

                queue.async {
                    let scheduler: SchedulerType = ConcurrentDispatchQueueScheduler(queue: queue, leeway: .milliseconds(5))

                    func makeSequence(label: String, period: RxTimeInterval) -> Observable<Int> {
                        return share(Observable<Int>.interval(period, scheduler: scheduler))
                    }

                    let _ = makeSequence(label: "main", period: 0.1)
                        .flatMapLatest { (index: Int) -> Observable<(Int, Int)> in
                            return makeSequence(label: "nested", period: 0.02).map { (index, $0) }
                        }
                        .take(10)
                        .enumerated().map { ($0, $1.0, $1.1) }
                        .subscribe(
                            onNext: { _ in },
                            onCompleted: {
                                expectation.fulfill()
                            } 
                    )
                }
            }

            waitForExpectations(timeout: 10.0) { (e) in
                XCTAssertNil(e)
            }
        }

        for op in [
                { $0.share(replay: 1) },
                { $0.replay(1).refCount() },
                { $0.publish().refCount() }
            ] as [(Observable<Int>) -> Observable<Int>] {
            performSharingOperatorsTest(share: op)
        }
    }

    func test1323() {
        func performSharingOperatorsTest(share: @escaping (Observable<Int>) -> Observable<Int>) {
            _ = share(Observable<Int>.create({ observer in
                    observer.on(.next(1))
                    Thread.sleep(forTimeInterval: 0.1)
                    observer.on(.completed)
                    return Disposables.create()
                })
                .flatMap { (int) -> Observable<Int> in
                    return Observable.create { (observer) -> Disposable in
                        DispatchQueue.global().async {
                            observer.onNext(int)
                            observer.onCompleted()
                        }
                        return Disposables.create()
                    }
                })
                .subscribe { (e) in
                }
        }

        for op in [
            { $0.share(replay: 0, scope: .whileConnected) },
            { $0.share(replay: 0, scope: .forever) },
            { $0.share(replay: 1, scope: .whileConnected) },
            { $0.share(replay: 1, scope: .forever) },
            { $0.share(replay: 2, scope: .whileConnected) },
            { $0.share(replay: 2, scope: .forever) },
            ] as [(Observable<Int>) -> Observable<Int>] {
            performSharingOperatorsTest(share: op)
        }
    }

    func test1344(){
        let disposeBag = DisposeBag()
        let foo = Observable<Int>.create({ observer in
                observer.on(.next(1))
                Thread.sleep(forTimeInterval: 0.1)
                observer.on(.completed)
                return Disposables.create()
            })
            .flatMap { (int) -> Observable<[Int]> in
                return Observable.create { (observer) -> Disposable in
                    DispatchQueue.global().async {
                        observer.onNext([int])
                    }
                    self.sleep(0.1)
                    return Disposables.create()
                }
            }

        Observable.merge(foo, .just([42]))
            .subscribe { (e) in
            }
            .disposed(by: disposeBag)
    }

    func testSeparationBetweenOnAndSubscriptionLocks() {
        func performSharingOperatorsTest(share: @escaping (Observable<Int>) -> Observable<Int>) {
            for i in 0 ..< 1 {
                let expectation = self.expectation(description: "wait until sequence completes")

                let queue = DispatchQueue(
                            label: "off main thread",
                            attributes: .concurrent
                        )

                queue.async {
                    func makeSequence(label: String, period: RxTimeInterval) -> Observable<Int> {
                        let schedulerQueue = DispatchQueue(
                            label: "Test",
                            attributes: .concurrent
                        )

                        let scheduler: SchedulerType = ConcurrentDispatchQueueScheduler(queue: schedulerQueue, leeway: .milliseconds(0))

                        return share(Observable<Int>.interval(period, scheduler: scheduler))
                    }

                    let _ = Observable.of(
                            makeSequence(label: "main", period: 0.2),
                            makeSequence(label: "nested", period: 0.3)
                        ).merge()
                        .take(1)
                        .subscribe(
                            onNext: { _ in
                                Thread.sleep(forTimeInterval: 0.4)
                            },
                            onCompleted: {
                                expectation.fulfill()
                        }
                    )
                }
            }

            waitForExpectations(timeout: 2.0) { (e) in
                XCTAssertNil(e)
            }
        }

        for op in [
            { $0.share(replay: 0, scope: .whileConnected) },
            { $0.share(replay: 0, scope: .forever) },
            { $0.share(replay: 1, scope: .whileConnected) },
            { $0.share(replay: 1, scope: .forever) },
            { $0.share(replay: 2, scope: .whileConnected) },
            { $0.share(replay: 2, scope: .forever) },
            ] as [(Observable<Int>) -> Observable<Int>] {
            performSharingOperatorsTest(share: op)
        }
    }
}
