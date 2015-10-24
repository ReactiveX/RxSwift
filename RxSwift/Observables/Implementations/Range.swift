//
//  Range.swift
//  Rx
//
//  Created by Krunoslav Zaher on 9/13/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class RangeProducer<_CompilerWorkaround> : Producer<Int> {
    private let _start: Int
    private let _count: Int
    private let _scheduler: ImmediateSchedulerType
    
    init(start: Int, count: Int, scheduler: ImmediateSchedulerType) {
        if count < 0 {
            rxFatalError("count can't be negative")
        }

        if start &+ (count - 1) < start {
            rxFatalError("overflow of count")
        }

        _start = start
        _count = count
        _scheduler = scheduler
    }
    
    override func run<O : ObserverType where O.E == Int>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = RangeSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}

class RangeSink<_CompilerWorkaround, O: ObserverType where O.E == Int> : Sink<O> {
    typealias Parent = RangeProducer<_CompilerWorkaround>
    
    private let _parent: Parent
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        _parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        return _parent._scheduler.scheduleRecursive(0) { i, recurse in
            if i < self._parent._count {
                self.observer?.on(.Next(self._parent._start + i))
                recurse(i + 1)
            }
            else {
                self.observer?.on(.Completed)
                self.dispose()
            }
        }
    }
}