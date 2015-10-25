//
//  Producer.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/20/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Producer<Element> : Observable<Element> {
    override init() {
        super.init()
    }
    
    override func subscribe<O : ObserverType where O.E == Element>(observer: O) -> Disposable {
        let sink = SingleAssignmentDisposable()
        let subscription = SingleAssignmentDisposable()
        
        let d = BinaryDisposable(sink, subscription)

        let setSink: (Disposable) -> Void = { d in sink.disposable = d }
        
        if !CurrentThreadScheduler.isScheduleRequired {
            let disposable = run(observer, cancel: subscription, setSink: setSink)
            
            subscription.disposable = disposable
        }
        else {
            CurrentThreadScheduler.instance.schedule(sink) { sink in
                let disposable = self.run(observer, cancel: subscription, setSink: setSink)
                subscription.disposable = disposable
                return NopDisposable.instance
            }
        }
        
        return d
    }
    
    func run<O : ObserverType where O.E == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        abstractMethod()
    }
}