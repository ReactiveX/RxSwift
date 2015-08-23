//
//  Reduce.swift
//  Rx
//
//  Created by Krunoslav Zaher on 4/1/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class ReduceSink<SourceType, AccumulateType, O: ObserverType> : Sink<O>, ObserverType {
    typealias ResultType = O.E
    typealias Parent = Reduce<SourceType, AccumulateType, ResultType>
    
    let parent: Parent
    var accumulation: AccumulateType
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        self.parent = parent
        
        self.accumulation = parent.seed
        
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<SourceType>) {
        switch event {
        case .Next(let value):
            do {
                self.accumulation = try parent.accumulator(accumulation, value)
            }
            catch let e {
                observer?.on(.Error(e))
                self.dispose()
            }
        case .Error(let e):
            observer?.on(.Error(e))
            self.dispose()
        case .Completed:
            do {
                let result = try parent.mapResult(self.accumulation)
                observer?.on(.Next(result))
                observer?.on(.Completed)
                self.dispose()
            }
            catch let e {
                observer?.on(.Error(e))
                self.dispose()
            }
        }
    }
}

class Reduce<SourceType, AccumulateType, ResultType> : Producer<ResultType> {
    typealias AccumulatorType = (AccumulateType, SourceType) throws -> AccumulateType
    typealias ResultSelectorType = (AccumulateType) throws -> ResultType
    
    let source: Observable<SourceType>
    let seed: AccumulateType
    let accumulator: AccumulatorType
    let mapResult: ResultSelectorType
    
    init(source: Observable<SourceType>, seed: AccumulateType, accumulator: AccumulatorType, mapResult: ResultSelectorType) {
        self.source = source
        self.seed = seed
        self.accumulator = accumulator
        self.mapResult = mapResult
    }
    
    override func run<O: ObserverType where O.E == ResultType>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = ReduceSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return source.subscribeSafe(sink)
    }
}