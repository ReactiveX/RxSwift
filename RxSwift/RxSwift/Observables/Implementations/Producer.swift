//
//  Producer.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/20/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public class Producer<Element> : Observable<Element> {
    public override init() {
        super.init()
    }
    
    public override func subscribe<O : ObserverType where O.Element == Element>(observer: O) -> Disposable {
        let sink = SingleAssignmentDisposable()
        let subscription = SingleAssignmentDisposable()
        
        let d = CompositeDisposable(sink, subscription)
        
        let setSink: (Disposable) -> Void = { d in sink.setDisposable(d) }
        let disposable = run(observer, cancel: subscription, setSink: setSink)
        
        subscription.setDisposable(disposable)
        
        return d
    }
    
    public func run<O : ObserverType where O.Element == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        return abstractMethod()
    }
}