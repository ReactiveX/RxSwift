//
//  Select.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Select_<SourceType, O : ObserverType> : Sink<O>, ObserverType {
    typealias ResultType = O.Element
    typealias Element = SourceType
    
    let parent: Select<SourceType, ResultType>
    
    init(parent: Select<SourceType, ResultType>, observer: O, cancel: Disposable) {
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

class Select_1<SourceType, O: ObserverType> : Select_<SourceType, O> {
    typealias ResultType = O.Element
    
    override init(parent: Select<SourceType, ResultType>, observer: O, cancel: Disposable) {
        super.init(parent: parent, observer: observer, cancel: cancel)
    }
    
    override func select(element: SourceType) -> RxResult<ResultType> {
        return (self.parent.selector1!)(element)
    }
}

class Select_2<SourceType, O: ObserverType> : Select_<SourceType, O> {
    typealias ResultType = O.Element
    
    var index = 0
    
    override init(parent: Select<SourceType, ResultType>, observer: O, cancel: Disposable) {
        super.init(parent: parent, observer: observer, cancel: cancel)
    }
    override func select(element: SourceType) -> RxResult<ResultType> {
        return (self.parent.selector2!)(element, index++)
    }
}

class Select<SourceType, ResultType>: Producer<ResultType> {
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
            let sink = Select_1(parent: self, observer: observer, cancel: cancel)
            setSink(sink)
            return self.source.subscribe(sink)
        }
        else {
            let sink = Select_2(parent: self, observer: observer, cancel: cancel)
            setSink(sink)
            return self.source.subscribe(sink)
        }
        
    }
}