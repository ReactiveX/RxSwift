//
//  Aggregate.swift
//  Rx
//
//  Created by Krunoslav Zaher on 4/1/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Aggregate_<SourceType, AccumulateType, ResultType> : Sink<ResultType>, ObserverType {
    typealias Element = SourceType
    typealias ParentType = Aggregate<SourceType, AccumulateType, ResultType>
    
    let parent: ParentType
    var accumulation: AccumulateType
    
    init(parent: ParentType, observer: ObserverOf<ResultType>, cancel: Disposable) {
        self.parent = parent
        
        self.accumulation = parent.seed
        
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<SourceType>) {
        switch event {
        case .Next(let boxedValue):
            let value = boxedValue.value
            parent.accumulator(accumulation, value) >== { result in
                self.accumulation = result
                return SuccessResult
            } >>! { e -> Result<Void> in
                self.observer.on(.Error(e))
                self.dispose()
                return SuccessResult
            }
        case .Error(let e):
            self.observer.on(.Error(e))
            self.dispose()
        case .Completed:
            parent.resultSelector(self.accumulation) >== { result in
                self.observer.on(.Next(Box(result)))
                self.observer.on(.Completed)
                self.dispose()
                return SuccessResult
            } >>! { error -> Result<Void> in
                self.observer.on(.Error(error))
                self.dispose()
                return SuccessResult
            }
        }
    }
}

class Aggregate<SourceType, AccumulateType, ResultType> : Producer<ResultType> {
    typealias AccumulatorType = (AccumulateType, SourceType) -> Result<AccumulateType>
    typealias ResultSelectorType = (AccumulateType) -> Result<ResultType>
    
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
    
    override func run(observer: ObserverOf<ResultType>, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = Aggregate_(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return source.subscribe(sink)
    }
}