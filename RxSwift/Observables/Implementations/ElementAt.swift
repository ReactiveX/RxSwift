//
//  ElementAt.swift
//  Rx
//
//  Created by Junior B. on 21/10/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation


class ElementAtSink<SourceType, O: ObserverType where O.E == SourceType> : Sink<O>, ObserverType {
    typealias Parent = ElementAt<SourceType>
    
    let _parent: Parent
    var _i: Int
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        _parent = parent
        _i = parent._index
        
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<SourceType>) {
        switch event {
        case .Next(_):

            if (_i == 0) {
                observer?.on(event)
                observer?.on(.Completed)
                self.dispose()
            }
            
            do {
                try decrementChecked(&_i)
            } catch(let e) {
                observer?.onError(e)
                dispose()
                return
            }
            
        case .Error(let e):
            observer?.on(.Error(e))
            self.dispose()
        case .Completed:
            if (_parent._throwOnEmpty) {
                observer?.onError(RxError.ArgumentOutOfRange)
            } else {
                observer?.on(.Completed)
            }
            
            self.dispose()
        }
    }
}

class ElementAt<SourceType> : Producer<SourceType> {
    
    let _source: Observable<SourceType>
    let _throwOnEmpty: Bool
    let _index: Int
    
    init(source: Observable<SourceType>, index: Int, throwOnEmpty: Bool) {
        if index < 0 {
            rxFatalError("index can't be negative")
        }

        self._source = source
        self._index = index
        self._throwOnEmpty = throwOnEmpty
    }
    
    override func run<O: ObserverType where O.E == SourceType>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = ElementAtSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return _source.subscribeSafe(sink)
    }
}