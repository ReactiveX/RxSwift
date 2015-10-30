//
//  AddRef.swift
//  Rx
//
//  Created by Junior B. on 30/10/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class AddRefSink<O: ObserverType> : Sink<O>, ObserverType {
    typealias Element = O.E
    
    override init(observer: O, cancel: Disposable) {
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<Element>) {
        switch event {
        case .Next(_):
            observer?.on(event)
        case .Completed, .Error(_):
            observer?.on(event)
            dispose()
        }
    }
}

class AddRef<Element> : Producer<Element> {
    typealias EventHandler = Event<Element> throws -> Void
    
    private let _source: Observable<Element>
    private let _refCount: RefCountDisposable
    
    init(source: Observable<Element>, refCount: RefCountDisposable) {
        _source = source
        _refCount = refCount
    }
    
    override func run<O: ObserverType where O.E == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let d = StableCompositeDisposable.create(_refCount.disposable, cancel)
        
        let sink = AddRefSink(observer: observer, cancel: d)
        setSink(sink)
        return _source.subscribeSafe(sink)
    }
}