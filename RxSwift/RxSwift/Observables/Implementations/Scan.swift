//
//  Scan.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/14/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class ScanSink<ElementType, Accumulate, O: ObserverType where O.Element == Accumulate> : Sink<O>, ObserverType {
    typealias Parent = Scan<ElementType, Accumulate>
    typealias Element = ElementType
    
    let parent: Parent
    var accumulate: Accumulate
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        self.parent = parent
        self.accumulate = parent.seed
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<ElementType>) {
        switch event {
        case .Next(let boxedElement):
            let element = boxedElement.value
            self.parent.accumulator(self.accumulate, element).map { result -> Void in
                self.accumulate = result
                trySendNext(observer, result)
            }.recover { error in
                trySendError(self.observer, error)
                self.dispose()
            }
        case .Error(let error):
            trySendError(observer, error)
            self.dispose()
        case .Completed:
            trySendCompleted(observer)
            self.dispose()
        }
    }
    
}

class Scan<Element, Accumulate>: Producer<Accumulate> {
    typealias Accumulator = (Accumulate, Element) -> RxResult<Accumulate>
    
    let source: Observable<Element>
    let seed: Accumulate
    let accumulator: Accumulator
    
    init(source: Observable<Element>, seed: Accumulate, accumulator: Accumulator) {
        self.source = source
        self.seed = seed
        self.accumulator = accumulator
    }
    
    override func run<O : ObserverType where O.Element == Accumulate>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = ScanSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return source.subscribeSafe(sink)
    }
}