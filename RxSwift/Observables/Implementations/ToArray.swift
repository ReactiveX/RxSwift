//
//  ToArray.swift
//  Rx
//
//  Created by Junior B. on 20/10/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class ToArraySink<SourceType, O: ObserverType where O.E == [SourceType]> : Sink<O>, ObserverType {
    typealias Parent = ToArray<SourceType>
    
    let _parent: Parent
    var _list = Array<SourceType>()
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        self._parent = parent
        
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<SourceType>) {
        switch event {
        case .Next(let value):
            self._list.append(value)
        case .Error(let e):
            observer?.on(.Error(e))
            self.dispose()
        case .Completed:
            observer?.on(.Next(_list))
            observer?.on(.Completed)
            self.dispose()
        }
    }
}

class ToArray<SourceType> : Producer<[SourceType]> {
    let _source: Observable<SourceType>

    init(source: Observable<SourceType>) {
        _source = source
    }
    
    override func run<O: ObserverType where O.E == [SourceType]>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = ToArraySink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return _source.subscribe(sink)
    }
}