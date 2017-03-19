//
//  Observable+Extensions.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 3/14/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxCocoa

extension Observable {
    public static func system<R>(
        _ initialState: R,
        accumulator: @escaping (R, Element) -> R,
        scheduler: SchedulerType,
        feedback: (Observable<R>) -> Observable<Element>...
    ) -> Observable<R> {
        return Observable<R>.deferred {
            let replaySubject = ReplaySubject<R>.create(bufferSize: 1)

            let inputs: Observable<Element> = Observable.merge(feedback.map { $0(replaySubject.asObservable()) })
                .observeOn(scheduler)

            return inputs.scan(initialState, accumulator: accumulator)
                .startWith(initialState)
                .do(onNext: { output in
                    replaySubject.onNext(output)
                })
        }
    }
}

extension SharedSequence {
    /**
     This operator models system with feedback loops.
    */
    public static func system<R>(
        _ initialState: R,
        accumulator: @escaping (R, E) -> R,
        feedback: (SharedSequence<S, R>) -> SharedSequence<S, Element>...
    ) -> SharedSequence<S, R> {
        return SharedSequence<S, R>.deferred {
            let replaySubject = ReplaySubject<R>.create(bufferSize: 1)

            let outputDriver = replaySubject.asSharedSequence(onErrorDriveWith: SharedSequence<S, R>.empty())

            let inputs = SharedSequence.merge(feedback.map { $0(outputDriver) })

            return inputs.scan(initialState, accumulator: accumulator)
                .startWith(initialState)
                .do(onNext: { output in
                    replaySubject.onNext(output)
                })
        }
    }
}
