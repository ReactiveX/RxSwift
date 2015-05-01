//
//  Producer.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/20/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Producer<Element> : Observable<Element> {
    override func subscribe(observer: ObserverOf<Element>) -> Disposable {
        let sink = SingleAssignmentDisposable()
        let subscription = SingleAssignmentDisposable()
        
        let d = CompositeDisposable(sink, subscription)
        
        let setSink: (Disposable) -> Void = { d in sink.setDisposable(d) }
        let disposable = run(observer, cancel: subscription, setSink: setSink)
        
        subscription.setDisposable(disposable)
        
        return d
    }
    
    func run(observer: ObserverOf<Element>, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        return abstractMethod()
    }
}