//
//  Generate.swift
//  Rx
//
//  Created by Krunoslav Zaher on 9/2/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class GenerateSink<S, O: ObserverType> : Sink<O> {
    typealias Parent = Generate<S, O.E>
    
    let parent: Parent
    
    var state: S
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        self.parent = parent
        self.state = parent.initialState
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        return parent.scheduler.scheduleRecursive(true) { (isFirst, recurse) -> Void in
            do {
                if !isFirst {
                    self.state = try self.parent.iterate(self.state)
                }
                
                if try self.parent.condition(self.state) {
                    let result = try self.parent.resultSelector(self.state)
                    self.observer?.on(.Next(result))
                    
                    recurse(false)
                }
                else {
                    self.observer?.on(.Completed)
                    self.dispose()
                }
            }
            catch let error {
                self.observer?.on(.Error(error))
                self.dispose()
            }
        }
    }
}

class Generate<S, E> : Producer<E> {
    let initialState: S
    let condition: S throws -> Bool
    let iterate: S throws -> S
    let resultSelector: S throws -> E
    let scheduler: ImmediateSchedulerType
    
    init(initialState: S, condition: S throws -> Bool, iterate: S throws -> S, resultSelector: S throws -> E, scheduler: ImmediateSchedulerType) {
        self.initialState = initialState
        self.condition = condition
        self.iterate = iterate
        self.resultSelector = resultSelector
        self.scheduler = scheduler
        super.init()
    }
    
    override func run<O : ObserverType where O.E == E>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = GenerateSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}