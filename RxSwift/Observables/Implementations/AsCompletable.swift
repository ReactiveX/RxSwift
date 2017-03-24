//
//  AsCompletable.swift
//  RxSwift
//
//  Created by Mostafa Amer on 23/03/2017.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

fileprivate final class AsCompletableSink<O: ObserverType> : Sink<O>, ObserverType {
    typealias ElementType = O.E
    typealias E = ElementType
    
    private var _element: Event<E>? = nil
    
    func on(_ event: Event<E>) {
        switch event {
        case .next:
            forwardOn(.error(RxError.someElements))
        case .error:
            forwardOn(event)
        case .completed:
            forwardOn(.completed)
        }
        dispose()
    }
}

final class AsCompletable<Element>: Producer<Swift.Never> {
    fileprivate let _source: Observable<Element>
    
    init(source: Observable<Element>) {
        _source = source
    }
    
    override func run<O : ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == Element {
        let sink = AsCompletableSink(observer: observer, cancel: cancel)
        let subscription = _source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
    
}
