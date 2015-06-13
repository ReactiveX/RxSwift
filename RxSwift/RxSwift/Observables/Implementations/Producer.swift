//
//  Producer.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/20/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// Base class for implementation of query operators, providing performance benefits over the use of `create`
// They are also responsible for ensuring correct message grammar and disposal grammar.
//
// That assumption enables big performance gain, but rogue `Producers` can bring system into
// an invalid state.
//
// For that reason, extreme care is needed when subclassing `Producer`. It's code correctness must be proven
// and it needs to be thorougly tested.
public class Producer<Element> : Observable<Element> {
    public override init() {
        super.init()
    }
    
    public override func subscribe<O : ObserverType where O.Element == Element>(observer: O) -> Disposable {
        return self.subscribeRaw(observer, enableSafeguard: true)
    }
    
    public func subscribeRaw<O : ObserverType where O.Element == Element>(observer: O, enableSafeguard: Bool) -> Disposable {
        let resultObserver: Observer<Element>
        
        let sink = SingleAssignmentDisposable()
        let subscription = SingleAssignmentDisposable()
        
        let d = CompositeDisposable(sink, subscription)

        if enableSafeguard {
            resultObserver = makeSafe(observer, d)
        }
        else {
            resultObserver = Observer.normalize(observer)
        }
        
        let setSink: (Disposable) -> Void = { d in sink.disposable = d }
        let disposable = run(observer, cancel: subscription, setSink: setSink)
        
        subscription.disposable = disposable
        
        return d
    }
    
    public func run<O : ObserverType where O.Element == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        return abstractMethod()
    }
}