//
//  Aggregate.swift
//  Rx
//
//  Created by Krunoslav Zaher on 4/1/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Aggregate_<SourceType, AccumulateType, O: ObserverType> : Sink<O>, ObserverType {
    typealias ResultType = O.Element
    typealias ParentType = Aggregate<SourceType, AccumulateType, ResultType>
    
    let parent: ParentType
    var accumulation: AccumulateType
    
    init(parent: ParentType, observer: O, cancel: Disposable) {
        self.parent = parent
        
        self.accumulation = parent.seed
        
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<SourceType>) {
        switch event {
        case .Next(let boxedValue):
            let value = boxedValue.value
            parent.accumulator(accumulation, value).flatMap { result in
                self.accumulation = result
                return SuccessResult
            }.recoverWith { e -> RxResult<Void> in
                trySendError(observer, e)
                self.dispose()
                return SuccessResult
            }
        case .Error(let e):
            trySendError(observer, e)
            self.dispose()
        case .Completed:
            parent.resultSelector(self.accumulation).flatMap { result in
                trySendNext(observer, result)
                trySendCompleted(observer)
                self.dispose()
                return SuccessResult
            }.recoverWith { error -> RxResult<Void> in
                trySendError(observer, error)
                self.dispose()
                return SuccessResult
            }
        }
    }
}

class Aggregate<SourceType, AccumulateType, ResultType> : Producer<ResultType> {
    typealias AccumulatorType = (AccumulateType, SourceType) -> RxResult<AccumulateType>
    typealias ResultSelectorType = (AccumulateType) -> RxResult<ResultType>
    
    let source: Observable<SourceType>
    let seed: AccumulateType
    let accumulator: AccumulatorType
    let resultSelector: ResultSelectorType
    
    init(source: Observable<SourceType>, seed: AccumulateType, accumulator: AccumulatorType, resultSelector: ResultSelectorType) {
        self.source = source
        self.seed = seed
        self.accumulator = accumulator
        self.resultSelector = resultSelector
    }
    
    override func run<O: ObserverType where O.Element == ResultType>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = Aggregate_(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return source.subscribeSafe(sink)
    }
}