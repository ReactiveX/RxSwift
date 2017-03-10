//
//  Materialize.swift
//  Rx
//
//  Created by sergdort on 08/03/2017.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import Foundation

public protocol EventType {
    associatedtype E
    func asEvent() -> Event<E>
}

extension Event : EventType {
    public typealias E = Element
    public func asEvent() -> Event<E> { return self }
}

fileprivate final class MaterializeSink<Element>: Disposable, ObserverType {
    private let _observer: AnyObserver<Event<Element>>
    private let _cancel: Cancelable
    private var _disposed: Bool
    
    init(observer: AnyObserver<Event<Element>>, cancel: Cancelable) {
        #if TRACE_RESOURCES
            let _ = Resources.incrementTotal()
        #endif
        _observer = observer
        _cancel = cancel
        _disposed = false
    }
    
    func on(_ event: Event<Element>) {
        if _disposed {
            return
        }
        _observer.onNext(event)
        if event.isStopEvent {
            _observer.onCompleted()
            dispose()
        }
    }
    
    func dispose() {
        _disposed = true
        _cancel.dispose()
    }
    
    deinit {
        #if TRACE_RESOURCES
            let _ =  Resources.decrementTotal()
        #endif
    }
}

final class Materialize<E>: Producer<Event<E>> {
    private let _source: Observable<E.E>
    
    init(source: Observable<E.E>) {
        _source = source
    }

    override func run<O: ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == E {
        let sink = MaterializeSink(observer: observer.asObserver(), cancel: cancel)
        let subscription = _source.subscribe(sink)

        return (sink: sink, subscription: subscription)
    }

}
