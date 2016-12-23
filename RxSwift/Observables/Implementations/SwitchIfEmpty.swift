//
//  SwitchIfEmpty.swift
//  Rx
//
//  Created by sergdort on 23/12/2016.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

final class SwitchIfEmptySink<SourceType, S: ObservableConvertibleType, O: ObserverType>: Sink<O>
    , ObserverType
    , LockOwnerType
    , SynchronizedOnType where S.E == O.E, SourceType == S.E {
    typealias E = SourceType
    typealias Selector = (Void) throws -> S
    
    let _lock = NSRecursiveLock()
    private let _selector: Selector
    fileprivate var isEmpty = true
    fileprivate let _subscriptions: SingleAssignmentDisposable = SingleAssignmentDisposable()
    fileprivate let _innerSubscription: SerialDisposable = SerialDisposable()
    
    init(selector: @escaping Selector, observer: O, cancel: Cancelable) {
        _selector = selector
        super.init(observer: observer, cancel: cancel)
    }
    
    func run(_ source: Observable<SourceType>) -> Disposable {
        let subscription = source.subscribe(self)
        _subscriptions.setDisposable(subscription)
        return Disposables.create(_subscriptions, _innerSubscription)
    }
    
    func on(_ event: Event<E>) {
        synchronizedOn(event)
    }
    
    func _synchronized_on(_ event: Event<E>) {
        switch event {
        case .next:
            isEmpty = false
            forwardOn(event)
        case .error:
            forwardOn(event)
            dispose()
        case .completed:
            if isEmpty {
                do {
                    let observable = try _selector().asObservable()
                    let d = SingleAssignmentDisposable()
                    _innerSubscription.disposable = d
                    
                    let observer = SwitchIfEmptySinkIter(parent: self, _self: d)
                    let disposable = observable.subscribe(observer)
                    d.setDisposable(disposable)
                } catch let error {
                    forwardOn(.error(error))
                    dispose()
                }
            } else {
                forwardOn(.completed)
                dispose()
            }
        }
    }
}

final class SwitchIfEmptySinkIter<SourceType, S: ObservableConvertibleType, O: ObserverType>
    : ObserverType
    , LockOwnerType
    , SynchronizedOnType where S.E == O.E, SourceType == S.E {
    typealias E = SourceType
    typealias Parent = SwitchIfEmptySink<SourceType, S, O>
    
    let _lock = NSRecursiveLock()
    fileprivate let _parent: Parent
    fileprivate let _self: Disposable
    
    init(parent: Parent, _self: Disposable) {
        _parent = parent
        self._self = _self
    }
    
    func on(_ event: Event<E>) {
        synchronizedOn(event)
    }
    
    func _synchronized_on(_ event: Event<E>) {
        switch event {
        case .next: break
        case .error, .completed:
            _self.dispose()
        }
        
        switch event {
        case .next:
            _parent.forwardOn(event)
        case .error:
            _parent.forwardOn(event)
            _parent.dispose()
        case .completed:
            _parent.isEmpty = false
            _parent.forwardOn(event)
            _parent.dispose()
        }
    }
}

final class SwitchIfEmpty<SourceType, S: ObservableConvertibleType>: Producer<S.E> where S.E == SourceType {
    
    typealias Selector = (Void) throws -> S
    
    fileprivate let _source: Observable<SourceType>
    fileprivate let _resultSelector: Selector
    
    init(source: Observable<SourceType>, resultSelector: @escaping Selector) {
        _source = source
        _resultSelector = resultSelector
    }
    
    override func run<O : ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == S.E {
        let sink = SwitchIfEmptySink(selector: _resultSelector,
                                     observer: observer,
                                     cancel: cancel)
        let subscription = sink.run(_source)
        
        return (sink: sink, subscription: subscription)
    }
}
