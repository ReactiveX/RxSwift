//
//  Just.swift
//  Rx
//
//  Created by Krunoslav Zaher on 8/30/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class JustScheduledSink<O: ObserverType> : Sink<O> {
    typealias Parent = JustScheduled<O.E>

    private let _parent: Parent

    init(parent: Parent, observer: O) {
        _parent = parent
        super.init(observer: observer)
    }

    func run() -> Disposable {
        let scheduler = _parent._scheduler
        return scheduler.schedule(_parent._element) { element in
            self.forwardOn(.next(element))
            return scheduler.schedule(()) { _ in
                self.forwardOn(.completed)
                return NopDisposable.instance
            }
        }
    }
}

class JustScheduled<Element> : Producer<Element> {
    private let _scheduler: ImmediateSchedulerType
    private let _element: Element

    init(element: Element, scheduler: ImmediateSchedulerType) {
        _scheduler = scheduler
        _element = element
    }

    override func subscribe<O : ObserverType where O.E == E>(_ observer: O) -> Disposable {
        let sink = JustScheduledSink(parent: self, observer: observer)
        sink.disposable = sink.run()
        return sink
    }
}

class Just<Element> : Producer<Element> {
    private let _element: Element
    
    init(element: Element) {
        _element = element
    }
    
    override func subscribe<O : ObserverType where O.E == Element>(_ observer: O) -> Disposable {
        observer.on(.next(_element))
        observer.on(.completed)
        return NopDisposable.instance
    }
}
