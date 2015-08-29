//
//  FlatMap.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/11/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// It's value is one because initial source subscription is always in CompositeDisposable
let FlatMapNoIterators = 1

class FlatMapSinkIter<SourceType, S: ObservableType, O: ObserverType where O.E == S.E> : ObserverType {
    typealias Parent = FlatMapSink<SourceType, S, O>
    typealias DisposeKey = CompositeDisposable.DisposeKey
    typealias E = O.E
    
    let parent: Parent
    let disposeKey: DisposeKey
    
    init(parent: Parent, disposeKey: DisposeKey) {
        self.parent = parent
        self.disposeKey = disposeKey
    }
    
    func on(event: Event<E>) {
        switch event {
        case .Next(let value):
            parent.lock.performLocked {
                parent.observer?.on(.Next(value))
            }
        case .Error(let error):
            parent.lock.performLocked {
                parent.observer?.on(.Error(error))
                self.parent.dispose()
            }
        case .Completed:
            parent.group.removeDisposable(disposeKey)
            // If this has returned true that means that `Completed` should be sent.
            // In case there is a race who will sent first completed,
            // lock will sort it out. When first Completed message is sent
            // it will set observer to nil, and thus prevent further complete messages
            // to be sent, and thus preserving the sequence grammar.
            if parent.stopped && parent.group.count == FlatMapNoIterators {
                parent.lock.performLocked {
                    parent.observer?.on(.Completed)
                    self.parent.dispose()
                }
            }
        }
    }
}

class FlatMapSink<SourceType, S: ObservableType, O: ObserverType where O.E == S.E> : Sink<O>, ObserverType {
    typealias ResultType = O.E
    typealias Element = SourceType
    typealias Parent = FlatMap<SourceType, S>
    
    let parent: Parent
    
    let lock = NSRecursiveLock()
    let group = CompositeDisposable()
    let sourceSubscription = SingleAssignmentDisposable()
    
    var stopped = false
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func performMap(element: SourceType) throws -> S {
        return abstractMethod()
    }
    
    func on(event: Event<SourceType>) {
        let observer = super.observer
        
        switch event {
        case .Next(let element):
            do {
                let value = try performMap(element)
                subscribeInner(value.asObservable())
            }
            catch let e {
                observer?.on(.Error(e))
                self.dispose()
            }
        case .Error(let error):
            lock.performLocked {
                observer?.on(.Error(error))
                self.dispose()
            }
        case .Completed:
            lock.performLocked {
                final()
            }
        }
    }
    
    func final() {
        stopped = true
        if group.count == FlatMapNoIterators {
            lock.performLocked {
                observer?.on(.Completed)
                dispose()
            }
        }
        else {
            self.sourceSubscription.dispose()
        }
    }
    
    func subscribeInner(source: Observable<O.E>) {
        let iterDisposable = SingleAssignmentDisposable()
        if let disposeKey = group.addDisposable(iterDisposable) {
            let iter = FlatMapSinkIter(parent: self, disposeKey: disposeKey)
            let subscription = source.subscribeSafe(iter)
            iterDisposable.disposable = subscription
        }
    }
    
    func run() -> Disposable {
        group.addDisposable(sourceSubscription)

        let subscription = self.parent.source.subscribeSafe(self)
        sourceSubscription.disposable = subscription
        
        return group
    }
}

class FlatMapSink1<SourceType, S: ObservableType, O : ObserverType where S.E == O.E> : FlatMapSink<SourceType, S, O> {
    override init(parent: Parent, observer: O, cancel: Disposable) {
        super.init(parent: parent, observer: observer, cancel: cancel)
    }
    
    override func performMap(element: SourceType) throws -> S {
        return try self.parent.selector1!(element)
    }
}

class FlatMapSink2<SourceType, S: ObservableType, O: ObserverType where S.E == O.E> : FlatMapSink<SourceType, S, O> {
    var index = 0
    
    override init(parent: Parent, observer: O, cancel: Disposable) {
        super.init(parent: parent, observer: observer, cancel: cancel)
    }
    
    override func performMap(element: SourceType) throws -> S {
        return try self.parent.selector2!(element, index++)
    }
}

class FlatMap<SourceType, S: ObservableType>: Producer<S.E> {
    typealias Selector1 = (SourceType) throws -> S
    typealias Selector2 = (SourceType, Int) throws -> S
    
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
    
    override func run<O: ObserverType where O.E == S.E>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        if let _ = self.selector1 {
            let sink = FlatMapSink1(parent: self, observer: observer, cancel: cancel)
            setSink(sink)
            return sink.run()
        }
        else {
            let sink = FlatMapSink2(parent: self, observer: observer, cancel: cancel)
            setSink(sink)
            return sink.run()
        }
        
    }
}