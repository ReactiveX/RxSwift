//
//  Anomalies.swift
//  Tests
//
//  Created by Krunoslav Zaher on 10/22/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Dispatch
import RxCocoa
import RxSwift
import RxTest
import XCTest

import Foundation

/**
 Makes sure github anomalies and edge cases don't surface up again.
 */
class AnomaliesTest: RxTest {}

extension AnomaliesTest {
    func test936() {
        func performSharingOperatorsTest(share: @escaping (Observable<Int>) -> Observable<Int>) {
            let queue = DispatchQueue(
                label: "Test",
                attributes: .concurrent // commenting this to use a serial queue remove the issue
            )

            for _ in 0 ..< 10 {
                let expectation = expectation(description: "wait until sequence completes")

                queue.async {
                    let scheduler: SchedulerType = ConcurrentDispatchQueueScheduler(queue: queue, leeway: .milliseconds(5))

                    func makeSequence(label _: String, period: RxTimeInterval) -> Observable<Int> {
                        share(Observable<Int>.interval(period, scheduler: scheduler))
                    }

                    _ = makeSequence(label: "main", period: .milliseconds(100))
                        .flatMapLatest { (index: Int) -> Observable<(Int, Int)> in
                            return makeSequence(label: "nested", period: .milliseconds(20)).map { (index, $0) }
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

            waitForExpectations(timeout: 10.0) { e in
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
            _ = share(Observable<Int>.create { observer in
                observer.on(.next(1))
                Thread.sleep(forTimeInterval: 0.1)
                observer.on(.completed)
                return Disposables.create()
            }
            .flatMap { int -> Observable<Int> in
                return Observable.create { observer -> Disposable in
                    DispatchQueue.global().async {
                        observer.onNext(int)
                        observer.onCompleted()
                    }
                    return Disposables.create()
                }
            })
            .subscribe()
        }

        for op in [
            { $0.share(replay: 0, scope: .whileConnected) },
            { $0.share(replay: 0, scope: .forever) },
            { $0.share(replay: 1, scope: .whileConnected) },
            { $0.share(replay: 1, scope: .forever) },
            { $0.share(replay: 2, scope: .whileConnected) },
            { $0.share(replay: 2, scope: .forever) }
        ] as [(Observable<Int>) -> Observable<Int>] {
            performSharingOperatorsTest(share: op)
        }
    }

    func test1344() {
        let disposeBag = DisposeBag()
        let foo = Observable<Int>.create { observer in
            observer.on(.next(1))
            Thread.sleep(forTimeInterval: 0.1)
            observer.on(.completed)
            return Disposables.create()
        }
        .flatMap { int -> Observable<[Int]> in
            return Observable.create { observer -> Disposable in
                DispatchQueue.global().async {
                    observer.onNext([int])
                }
                self.sleep(0.1)
                return Disposables.create()
            }
        }

        Observable.merge(foo, .just([42]))
            .subscribe()
            .disposed(by: disposeBag)
    }

    func testSeparationBetweenOnAndSubscriptionLocks() {
        func performSharingOperatorsTest(share: @escaping (Observable<Int>) -> Observable<Int>) {
            for _ in 0 ..< 1 {
                let expectation = expectation(description: "wait until sequence completes")

                let queue = DispatchQueue(
                    label: "off main thread",
                    attributes: .concurrent
                )

                queue.async {
                    func makeSequence(label _: String, period: RxTimeInterval) -> Observable<Int> {
                        let schedulerQueue = DispatchQueue(
                            label: "Test",
                            attributes: .concurrent
                        )

                        let scheduler: SchedulerType = ConcurrentDispatchQueueScheduler(queue: schedulerQueue, leeway: .milliseconds(0))

                        return share(Observable<Int>.interval(period, scheduler: scheduler))
                    }

                    _ = Observable.of(
                        makeSequence(label: "main", period: .milliseconds(200)),
                        makeSequence(label: "nested", period: .milliseconds(300))
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

            waitForExpectations(timeout: 2.0) { e in
                XCTAssertNil(e)
            }
        }

        for op in [
            { $0.share(replay: 0, scope: .whileConnected) },
            { $0.share(replay: 0, scope: .forever) },
            { $0.share(replay: 1, scope: .whileConnected) },
            { $0.share(replay: 1, scope: .forever) },
            { $0.share(replay: 2, scope: .whileConnected) },
            { $0.share(replay: 2, scope: .forever) }
        ] as [(Observable<Int>) -> Observable<Int>] {
            performSharingOperatorsTest(share: op)
        }
    }

    func test2653ShareReplayOneInitialEmissionDeadlock() {
        let immediatelyEmittingSource = Observable<Void>.create { observer in
            observer.on(.next(()))
            return Disposables.create()
        }
        .share(replay: 1, scope: .whileConnected)

        let exp = createInitialEmissionsDeadlockExpectation(
            sourceName: "`share(replay: 1, scope: .whileConnected)`",
            immediatelyEmittingSource: immediatelyEmittingSource
        )

        wait(for: [exp], timeout: 5)
    }

    func test2653ShareReplayMoreInitialEmissionDeadlock() {
        let immediatelyEmittingSource = Observable<Void>.create { observer in
            observer.on(.next(()))
            return Disposables.create()
        }
        .share(replay: 2, scope: .whileConnected)

        let exp = createInitialEmissionsDeadlockExpectation(
            sourceName: "`share(replay: 2, scope: .whileConnected)`",
            immediatelyEmittingSource: immediatelyEmittingSource
        )

        wait(for: [exp], timeout: 5)
    }

    func test2653ShareReplayOneForeverInitialEmissionDeadlock() {
        let immediatelyEmittingSource = Observable<Void>.create { observer in
            observer.on(.next(()))
            return Disposables.create()
        }
        .share(replay: 1, scope: .forever)

        let exp = createInitialEmissionsDeadlockExpectation(
            sourceName: "`share(replay: 1, scope: .forever)`",
            immediatelyEmittingSource: immediatelyEmittingSource
        )

        wait(for: [exp], timeout: 5)
    }

    func test2653ShareReplayMoreForeverInitialEmissionDeadlock() {
        let immediatelyEmittingSource = Observable<Void>.create { observer in
            observer.on(.next(()))
            return Disposables.create()
        }
        .share(replay: 2, scope: .forever)

        let exp = createInitialEmissionsDeadlockExpectation(
            sourceName: "`share(replay: 2, scope: .forever)`",
            immediatelyEmittingSource: immediatelyEmittingSource
        )

        wait(for: [exp], timeout: 5)
    }

    private func createInitialEmissionsDeadlockExpectation(
        sourceName: String,
        immediatelyEmittingSource: Observable<Void>
    ) -> XCTestExpectation {
        let exp = expectation(description: "`\(sourceName)` doesn't cause a deadlock in multithreaded environment because it doesn't keep its lock acquired to replay values upon subscription")

        let triggerRange = 0 ..< 1000

        let multipleSubscriptions = Observable.zip(triggerRange.map { _ in
            Observable.just(())
                .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
                .flatMap { _ in
                    immediatelyEmittingSource
                }
                .take(1)
        })

        _ = multipleSubscriptions.subscribe(onCompleted: {
            exp.fulfill()
        })

        return exp
    }
}

extension AnomaliesTest {
    func test2713ReplaySubjectDoesntReplayWhileHoldingItsLock() {
        for _ in 0 ..< 3 {
            let subject = ReplaySubject<Int>.create(bufferSize: 1)
            subject.onNext(1)

            // Stands in for any lock an operator downstream of the subject might hold.
            let foreignLock = NSRecursiveLock()
            let foreignLockAcquired = DispatchSemaphore(value: 0)
            let replayStarted = DispatchSemaphore(value: 0)
            let replayAcquiredForeignLock = DispatchSemaphore(value: 0)
            let finished = DispatchGroup()

            // Holds the foreign lock, then reaches into the subject, which needs the subject's lock.
            finished.enter()
            DispatchQueue.global(qos: .userInitiated).async {
                foreignLock.lock()
                foreignLockAcquired.signal()
                XCTAssertEqual(replayStarted.wait(timeout: .now() + 5), .success)
                _ = subject.subscribe()
                foreignLock.unlock()
                finished.leave()
            }

            // Subscribes, so the buffered value is replayed into an observer that needs the foreign lock.
            finished.enter()
            DispatchQueue.global(qos: .userInitiated).async {
                XCTAssertEqual(foreignLockAcquired.wait(timeout: .now() + 5), .success)

                let subscription = subject.subscribe(onNext: { _ in
                    replayStarted.signal()

                    // Deadlocks here if the replay is performed while the subject's lock is held:
                    // the foreign lock is owned by a thread already blocked on the subject's lock.
                    if foreignLock.lock(before: Date().addingTimeInterval(2)) {
                        foreignLock.unlock()
                        replayAcquiredForeignLock.signal()
                    }
                })

                subscription.dispose()
                finished.leave()
            }

            XCTAssertEqual(finished.wait(timeout: .now() + 20), .success)
            XCTAssertEqual(
                replayAcquiredForeignLock.wait(timeout: .now() + 5),
                .success,
                "`ReplaySubject` replayed its buffer while holding its own lock, deadlocking against an unrelated lock held downstream"
            )
        }
    }
}
