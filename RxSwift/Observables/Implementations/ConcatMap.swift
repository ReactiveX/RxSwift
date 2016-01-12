//
//  ConcatMap.swift
//  Rx
//
//  Created by Mike Lewis on 1/12/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

final class ConcatMapSink<SourceType, S: ObservableConvertibleType, O: ObserverType where O.E == S.E> : Sink<O>
, ObserverType {
    typealias Selector = (SourceType) throws -> S
    
    typealias E = SourceType
    
    private let _selector: Selector
    
    private let _currentSubscription = SerialDisposable()

    private let _sourceSubscription = SingleAssignmentDisposable()
    
    private var _enqueuedObservables = Queue<Event<SourceType>>(capacity: 1)
    
    private var _obserableLock = SpinLock()
    
    private let _scheduler = CurrentThreadScheduler.instance
    
    /// This is used to determine who iterates on the observable
    private var _isIterating: AtomicInt = 0
    
    private let _compositeDisposable: CompositeDisposable
    
    init(selector: Selector, observer: O) {
        _selector = selector
        _compositeDisposable = CompositeDisposable(_sourceSubscription, _currentSubscription)
        super.init(observer: observer)
    }
    
    func on(event: Event<SourceType>) {
        _obserableLock.calculateLocked {
            _enqueuedObservables.enqueue(event)
        }
        scheduleIteration()
    }
    
    func run(source: Observable<SourceType>) -> Disposable {
        _sourceSubscription.disposable = source.subscribe(self)
        return _compositeDisposable;
    }
    
    /// Schedules iteration until we run out of stuff in our queue
    private func scheduleIteration() {
        
        let singleDisposable = SingleAssignmentDisposable()
        
        guard let disposeKey = _compositeDisposable.addDisposable(singleDisposable) else {
            return
        }
        
        singleDisposable.disposable = _scheduler.scheduleRecursive(Void()) { _, recurse in
            self.tryIterating(recurse, disposeKey: disposeKey)
        }
    }
    
    /// - returns: true if we started iterating. It may consume immediately
    private func tryIterating(recurse: () -> (), disposeKey: CompositeDisposable.DisposeKey) {
        if self.disposed {
            return
        }
        
        if AtomicCompareAndSwap(0, 1, &_isIterating) {
            startIterating(recurse, disposeKey: disposeKey)
        } else {
            _compositeDisposable.removeDisposable(disposeKey)
        }
    }
    
    private func startIterating(recurse: () -> (), disposeKey: CompositeDisposable.DisposeKey) {
        guard let nextEvent = _obserableLock.calculateLocked({ _enqueuedObservables.dequeue() }) else {
            /// if se don't have a next event, we're done here
            _isIterating = 0
            return
        }
        switch nextEvent {
        case let .Next(nextSource):
            do {
                _currentSubscription.disposable = try _selector(nextSource).asObservable().subscribe { innerEvent in
                    switch innerEvent {
                    case .Completed:
                        self._isIterating = 0
                        recurse()
                    case let .Error(e):
                        self.forwardOn(.Error(e))
                        self.dispose()
                        self._isIterating = 0
                    case let .Next(v):
                        self.forwardOn(.Next(v))
                    }
                }
            } catch let e {
                self.forwardOn(.Error(e))
                self.dispose()
                _isIterating = 0
            }
        case let .Error(error):
            self.forwardOn(.Error(error))
            self.dispose()
            _isIterating = 0
        case .Completed:
            self.forwardOn(.Completed)
            self.dispose()
            _isIterating = 0
        }
    }
}

final class ConcatMap<SourceType, S: ObservableConvertibleType>: Producer<S.E> {
    typealias Selector = (SourceType) throws -> S
    
    private let _source: Observable<SourceType>
    
    private let _selector: Selector
    
    init(source: Observable<SourceType>, selector: Selector) {
        _source = source
        _selector = selector
    }
    
    override func run<O: ObserverType where O.E == S.E>(observer: O) -> Disposable {
        let sink = ConcatMapSink<SourceType, S, O>(selector: _selector, observer: observer)
        sink.disposable = sink.run(_source)
        return sink
    }
}
