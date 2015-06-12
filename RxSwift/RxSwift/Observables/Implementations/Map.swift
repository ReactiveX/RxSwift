//
//  Map.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class MapSink<SourceType, O : ObserverType> : Sink<O>, ObserverType {
    typealias ResultType = O.Element
    typealias Element = SourceType
    typealias Parent = Map<SourceType, ResultType>
    
    let parent: Parent
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func select(element: SourceType) -> RxResult<ResultType> {
        return abstractMethod()
    }

    func on(event: Event<SourceType>) {
        let observer = super.observer
        
        switch event {
        case .Next(let element):
            select(element.value).flatMap { value in
                trySendNext(observer, value)
                return SuccessResult
            }.recoverWith { e -> RxResult<Void> in
                trySendError(observer, e)
                self.dispose()
                return SuccessResult
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

class MapSink1<SourceType, O: ObserverType> : MapSink<SourceType, O> {
    typealias ResultType = O.Element
    
    override init(parent: Map<SourceType, ResultType>, observer: O, cancel: Disposable) {
        super.init(parent: parent, observer: observer, cancel: cancel)
    }
    
    override func select(element: SourceType) -> RxResult<ResultType> {
        return (self.parent.selector1!)(element)
    }
}

class MapSink2<SourceType, O: ObserverType> : MapSink<SourceType, O> {
    typealias ResultType = O.Element
    
    var index = 0
    
    override init(parent: Map<SourceType, ResultType>, observer: O, cancel: Disposable) {
        super.init(parent: parent, observer: observer, cancel: cancel)
    }
    override func select(element: SourceType) -> RxResult<ResultType> {
        return (self.parent.selector2!)(element, index++)
    }
}

class Map<SourceType, ResultType>: Producer<ResultType> {
    typealias Selector1 = (SourceType) -> RxResult<ResultType>
    typealias Selector2 = (SourceType, Int) -> RxResult<ResultType>
    
    let source: Observable<SourceType>
    
    let selector1: Selector1?
    let selector2: Selector2?
    
    init(source: Observable<SourceType>, selector: Selector1) {
        self.source = source
        self.selector1 = selector
        self.selector2 = nil
    }
    
    init(source: Observable<SourceType>, selector: Selector2) {
        self.source = source
        self.selector2 = selector
        self.selector1 = nil
    }
    
    override func run<O: ObserverType where O.Element == ResultType>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        if let selector1 = self.selector1 {
            let sink = MapSink1(parent: self, observer: observer, cancel: cancel)
            setSink(sink)
            return self.source.subscribeSafe(sink)
        }
        else {
            let sink = MapSink2(parent: self, observer: observer, cancel: cancel)
            setSink(sink)
            return self.source.subscribeSafe(sink)
        }
        
    }
}