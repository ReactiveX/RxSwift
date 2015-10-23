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
    
    let parent: Parent
    var i: Int
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        self.parent = parent
        self.i = parent.index
        
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<SourceType>) {
        switch event {
        case .Next(_):

            if i < 0 {
                rxFatalError("index can't be negative")
            }

            if (i == 0) {
                observer?.on(event)
                observer?.on(.Completed)
                self.dispose()
            }
            
            do {
                try decrementChecked(&i)
            } catch(let e) {
                observer?.onError(e)
                dispose()
                return
            }
            
        case .Error(let e):
            observer?.on(.Error(e))
            self.dispose()
        case .Completed:
            if (parent.throwOnEmpty) {
                observer?.onError(RxError.ArgumentOutOfRange)
            } else {
                observer?.on(.Completed)
            }
            
            self.dispose()
        }
    }
}

class ElementAt<SourceType> : Producer<SourceType> {
    
    let source: Observable<SourceType>
    let throwOnEmpty: Bool
    let index: Int
    
    init(source: Observable<SourceType>, index: Int, throwOnEmpty: Bool) {
        self.source = source
        self.index = index
        self.throwOnEmpty = throwOnEmpty
    }
    
    override func run<O: ObserverType where O.E == SourceType>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = ElementAtSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return source.subscribeSafe(sink)
    }
}