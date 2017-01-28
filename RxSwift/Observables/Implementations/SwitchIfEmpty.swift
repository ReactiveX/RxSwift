//
//  SwitchIfEmpty.swift
//  RxSwift
//
//  Created by sergdort on 23/12/2016.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation


final class SwitchIfEmpty<S: ObservableConvertibleType>: Producer<S.E> {
    
    private let _source: S
    private let _other: S
    
    init(source: S, other: S) {
        _source = source
        _other = other
    }
    
    override func run<O : ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == S.E {
        let sink = SwitchIfEmptySink(sequence: _other,
                                     observer: observer,
                                     cancel: cancel)
        let subscription = sink.run(_source.asObservable())
        
        return (sink: sink, subscription: subscription)
    }
}

final class SwitchIfEmptySink<S: ObservableConvertibleType, O: ObserverType>: Sink<O>
    , ObserverType where S.E == O.E {
    typealias E = O.E
    
    private let _sequence: S
    private var isEmpty = true
    private let _subscriptions: SingleAssignmentDisposable = SingleAssignmentDisposable()
    private let _innerSubscription: SerialDisposable = SerialDisposable()
    
    init(sequence: S, observer: O, cancel: Cancelable) {
        _sequence = sequence
        super.init(observer: observer, cancel: cancel)
    }
    
    func run(_ source: Observable<O.E>) -> Disposable {
        let subscription = source.subscribe(self)
        _subscriptions.setDisposable(subscription)
        return Disposables.create(_subscriptions, _innerSubscription)
    }
    
    func on(_ event: Event<E>) {
        switch event {
        case .next:
            isEmpty = false
            forwardOn(event)
        case .error:
            forwardOn(event)
            dispose()
        case .completed:
            guard isEmpty else {
                forwardOn(.completed)
                dispose()
                return
            }
            let observable = _sequence.asObservable()
            let d = SingleAssignmentDisposable()
            _innerSubscription.disposable = d
            let observer = SwitchIfEmptySinkIter(parent: self, _self: d)
            let disposable = observable.subscribe(observer)
            d.setDisposable(disposable)
        }
    }
}

final class SwitchIfEmptySinkIter<S: ObservableConvertibleType, O: ObserverType>
    : ObserverType where S.E == O.E {
    typealias E = O.E
    typealias Parent = SwitchIfEmptySink<S, O>
    
    private let _parent: Parent
    private let _self: Disposable
    
    init(parent: Parent, _self: Disposable) {
        _parent = parent
        self._self = _self
    }
    
    func on(_ event: Event<E>) {
        switch event {
        case .next:
            _parent.forwardOn(event)
        case .error:
            _parent.forwardOn(event)
            _self.dispose()
            _parent.dispose()
        case .completed:
            _parent.forwardOn(event)
            _self.dispose()
            _parent.dispose()
        }
    }
}
