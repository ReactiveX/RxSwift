//
//  Range.swift
//  Rx
//
//  Created by Krunoslav Zaher on 9/13/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class RangeProducer<E: SignedIntegerType> : Producer<E> {
    private let _start: E
    private let _count: E
    private let _scheduler: ImmediateSchedulerType

    init(start: E, count: E, scheduler: ImmediateSchedulerType) {
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
    
    override func run<O : ObserverType where O.E == E>(observer: O) -> Disposable {
        let sink = RangeSink(parent: self, observer: observer)
        sink.disposable = sink.run()
        return sink
    }
}

class RangeSink<O: ObserverType where O.E: SignedIntegerType> : Sink<O> {
    typealias Parent = RangeProducer<O.E>
    
    private let _parent: Parent
    
    init(parent: Parent, observer: O) {
        _parent = parent
        super.init(observer: observer)
    }
    
    func run() -> Disposable {
        return _parent._scheduler.scheduleRecursive(0 as O.E) { i, recurse in
            if i < self._parent._count {
                self.forwardOn(.Next(self._parent._start + i))
                recurse(i + 1)
            }
            else {
                self.forwardOn(.Completed)
                self.dispose()
            }
        }
    }
}