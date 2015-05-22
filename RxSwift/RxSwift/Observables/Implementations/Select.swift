//
//  Select.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Select_<ElementType, ResultType> : Sink<ResultType>, ObserverType {
    let parent: Select<ElementType, ResultType>
    
    init(parent: Select<ElementType, ResultType>, observer: ObserverOf<ResultType>, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func select(element: ElementType) -> RxResult<ResultType> {
        return abstractMethod()
    }

    func on(event: Event<ElementType>) {
        let observer = super.observer
        
        switch event {
        case .Next(let element):
            select(element.value).flatMap { value in
                sendNext(observer, value)
                return SuccessResult
            }.recoverWith { e -> RxResult<Void> in
                sendError(observer, e)
                self.dispose()
                return SuccessResult
            }
        case .Error(let error):
            sendError(observer, error)
            self.dispose()
        case .Completed:
            sendCompleted(observer)
            self.dispose()
        }
    }
}

class Select_1<ElementType, ResultType> : Select_<ElementType, ResultType> {
    
    override init(parent: Select<ElementType, ResultType>, observer: ObserverOf<ResultType>, cancel: Disposable) {
        super.init(parent: parent, observer: observer, cancel: cancel)
    }
    
    override func select(element: ElementType) -> RxResult<ResultType> {
        return (self.parent.selector1!)(element)
    }
}

class Select_2<ElementType, ResultType> : Select_<ElementType, ResultType> {
    var index = 0
    
    override init(parent: Select<ElementType, ResultType>, observer: ObserverOf<ResultType>, cancel: Disposable) {
        super.init(parent: parent, observer: observer, cancel: cancel)
    }
    override func select(element: ElementType) -> RxResult<ResultType> {
        return (self.parent.selector2!)(element, index++)
    }
}

class Select<ElementType, ResultType>: Producer<ResultType> {
    typealias Element = ElementType
    typealias Selector1 = (Element) -> RxResult<ResultType>
    typealias Selector2 = (Element, Int) -> RxResult<ResultType>
    
    let source: Observable<Element>
    
    let selector1: Selector1?
    let selector2: Selector2?
    
    init(source: Observable<Element>, selector: Selector1) {
        self.source = source
        self.selector1 = selector
        self.selector2 = nil
    }
    
    init(source: Observable<Element>, selector: Selector2) {
        self.source = source
        self.selector2 = selector
        self.selector1 = nil
    }
    
    override func run(observer: ObserverOf<ResultType>, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        var sink: Select_<ElementType, ResultType>
        if let selector1 = self.selector1 {
            sink = Select_1(parent: self, observer: observer, cancel: cancel)
        }
        else {
            sink = Select_2(parent: self, observer: observer, cancel: cancel)
        }
        
        setSink(sink)
            
        return self.source.subscribe(sink)
    }
}