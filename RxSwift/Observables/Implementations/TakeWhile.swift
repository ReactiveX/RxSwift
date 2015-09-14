//
//  TakeWhile.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/7/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class TakeWhileSink1<ElementType, O: ObserverType where O.E == ElementType> : Sink<O>, ObserverType {
    typealias Parent = TakeWhile<ElementType>
    typealias Element = ElementType

    let parent: Parent

    var running = true

    init(parent: Parent, observer: O, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<Element>) {
        if !running {
            return
        }
        switch event {
        case .Next(let value):
            
            running = self.parent.predicate1(value)

            if running  {
                observer?.on(.Next(value))
            }
            else {
                observer?.on(.Completed)
                self.dispose()
            }
        case .Error:
            observer?.on(event)
            self.dispose()
        case .Completed:
            observer?.on(event)
            self.dispose()
        }
    }
    
}

class TakeWhileSink2<ElementType, O: ObserverType where O.E == ElementType> : Sink<O>, ObserverType {
    typealias Parent = TakeWhile<ElementType>
    typealias Element = ElementType
    
    let parent: Parent
    
    var running = true
    var index = 0
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<Element>) {
        if !running {
            return
        }
        switch event {
        case .Next(let value):
            
            running = self.parent.predicate2(value, index)
            self.index = index + 1
            
            if running  {
                observer?.on(.Next(value))
            }
            else {
                observer?.on(.Completed)
                self.dispose()
            }
        case .Error:
            observer?.on(event)
            self.dispose()
        case .Completed:
            observer?.on(event)
            self.dispose()
        }
    }
    
}

class TakeWhile<Element>: Producer<Element> {
    typealias Predicate1 = (Element) -> Bool
    typealias Predicate2 = (Element, Int) -> Bool

    let source: Observable<Element>
    let predicate1: Predicate1!
    let predicate2: Predicate2!

    init(source: Observable<Element>, predicate: Predicate1) {
        self.source = source
        self.predicate1 = predicate
        self.predicate2 = nil
    }
    
    init(source: Observable<Element>, predicate: Predicate2) {
        self.source = source
        self.predicate1 = nil
        self.predicate2 = predicate
    }
    
    override func run<O : ObserverType where O.E == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        if let _ = self.predicate1 {
            let sink = TakeWhileSink1(parent: self, observer: observer, cancel: cancel)
            setSink(sink)
            return source.subscribeSafe(sink)
        }
        else {
            let sink = TakeWhileSink2(parent: self, observer: observer, cancel: cancel)
            setSink(sink)
            return source.subscribeSafe(sink)
        }
    }
}