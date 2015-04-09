//
//  Aggregate.swift
//  Rx
//
//  Created by Krunoslav Zaher on 4/1/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Aggregate_<SourceType, AccumulateType, ResultType> : Sink<ResultType>, ObserverClassType {
    typealias Element = SourceType
    typealias ParentType = Aggregate<SourceType, AccumulateType, ResultType>
    
    let parent: ParentType
    var accumulation: AccumulateType
    
    init(parent: ParentType, observer: ObserverOf<ResultType>, cancel: Disposable) {
        self.parent = parent
        
        self.accumulation = parent.seed
        
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<SourceType>) -> Result<Void> {
        switch event {
        case .Next(let boxedValue):
            let value = boxedValue.value
            return parent.accumulator(accumulation, value) >== { result in
                self.accumulation = result
                return SuccessResult
            } >>! { e in
                let result = self.observer.on(.Error(e))
                self.dispose()
                return result >>> { .Error(e) }
            }
        case .Error(let e):
            let result = self.observer.on(.Error(e))
            self.dispose()
            return result
        case .Completed:
            return self.parent.resultSelector(self.accumulation) >== { result in
                let result = self.observer.on(.Next(Box(result))) >>> {
                    self.observer.on(.Completed)
                }
                self.dispose()
                return result
            } >>! { error in
                let result = self.observer.on(.Error(error))
                self.dispose()
                return result
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
    
    override func run(observer: ObserverOf<ResultType>, cancel: Disposable, setSink: (Disposable) -> Void) -> Result<Disposable> {
        let sink = Aggregate_(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return source.subscribeSafe(ObserverOf(sink))
    }
}