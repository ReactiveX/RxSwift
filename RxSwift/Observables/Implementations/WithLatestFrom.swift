//
//  WithLatestFrom.swift
//  RxExample
//
//  Created by Yury Korolev on 10/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class WithLatestFromSink<FirstType, SecondType, ResultType, O: ObserverType where O.E == ResultType > : Sink<O>, ObserverType {
    
    typealias Parent = WithLatestFrom<FirstType, SecondType, ResultType>
    typealias E = FirstType
    
    private let _parent: Parent
    
    private var _lock = NSRecursiveLock()
    private var _latest: SecondType?
    
   
    init(parent: Parent, observer: O, cancel: Disposable) {
        _parent = parent
        
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        let sndSubscription = SingleAssignmentDisposable()
        let sndO = WithLatestFromSecond(parent: self, disposable: sndSubscription)
        
        let fstSubscription = _parent._first.subscribe(self)
        sndSubscription.disposable = _parent._second.subscribe(sndO)
        
        return StableCompositeDisposable.create(fstSubscription, sndSubscription)
    }
    
    func on(event: Event<E>) {
        _lock.performLocked {
            switch event {
            case let .Next(value):
                guard let latest = _latest else { return }
                do {
                    let res = try _parent._resultSelector(value, latest)
                    
                    observer?.onNext(res)
                } catch let e {
                    observer?.onError(e)
                    dispose()
                }
            case .Completed:
                observer?.onComplete()
                dispose()
            case let .Error(error):
                observer?.onError(error)
                dispose()
            }
        }
    }
}

class WithLatestFromSecond<FirstType, SecondType, ResultType, O: ObserverType where O.E == ResultType>: ObserverType {
    
    typealias Parent = WithLatestFromSink<FirstType, SecondType, ResultType, O>
    typealias E = SecondType
    
    private let _parent: Parent
    private let _disposable: Disposable
    
    init(parent: Parent, disposable: Disposable) {
        _parent = parent
        _disposable = disposable
    }
    
    func on(event: Event<E>) {
        switch event {
        case let .Next(value):
            _parent._lock.performLocked {
                _parent._latest = value
            }
        case .Completed:
            _disposable.dispose()
        case let .Error(error):
            _parent._lock.performLocked {
                _parent.observer?.onError(error)
                _parent.dispose()
            }
        }
    }

}

class WithLatestFrom<FirstType, SecondType, ResultType>: Producer<ResultType> {
    typealias ResultSelector = (FirstType, SecondType) throws -> ResultType
    
    private let _first: Observable<FirstType>
    private let _second: Observable<SecondType>
    private let _resultSelector: ResultSelector

    init(first: Observable<FirstType>, second: Observable<SecondType>, resultSelector: ResultSelector) {
        _first = first
        _second = second
        _resultSelector = resultSelector
    }
    
    override func run<O : ObserverType where O.E == ResultType>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        
        let sink = WithLatestFromSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}