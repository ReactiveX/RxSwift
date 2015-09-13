//
//  Range.swift
//  Rx
//
//  Created by Krunoslav Zaher on 9/13/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class RangeProducer<_CompilerWorkaround> : Producer<Int> {
    let start: Int
    let count: Int
    let scheduler: ImmediateSchedulerType
    
    init(start: Int, count: Int, scheduler: ImmediateSchedulerType) {
        self.start = start
        self.count = count
        self.scheduler = scheduler
    }
    
    override func run<O : ObserverType where O.E == Int>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = RangeSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}

class RangeSink<_CompilerWorkaround, O: ObserverType where O.E == Int> : Sink<O> {
    typealias Parent = RangeProducer<_CompilerWorkaround>
    
    let parent: Parent
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        return self.parent.scheduler.scheduleRecursive(0) { i, recurse in
            if i < self.parent.count {
                self.observer?.on(.Next(self.parent.start + i))
                recurse(i + 1)
            }
            else {
                self.observer?.on(.Completed)
                self.dispose()
            }
        }
    }
}