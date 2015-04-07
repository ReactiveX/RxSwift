//
//  Variable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public class Variable<Element>: Subject<Element> {
    typealias VariableState = Element
    
    var lock = Lock()
    var replayEvent: Event<Element>? = nil
    
    public init(_ initialEvent: Event<Element>) {
        self.replayEvent = initialEvent
        super.init()
    }
    
    public override init() {
        super.init()
    }
    
    public override func on(event: Event<Element>) -> Result<Void> {
        switch event {
        case .Next:
            lock.performLocked {
                self.replayEvent = event
            }
        default: break
        }
        
        return super.on(event)
    }

    public override func subscribe(observer: ObserverOf<Element>) -> Result<Disposable> {
        var result: Result<Void>
        
        var currentValue = self.lock.calculateLocked { self.replayEvent }
        
        if let currentValue = currentValue {
            result = observer.on(currentValue)
        }
        else {
            result = SuccessResult
        }
        
        if let error = result.error {
            dispose()
            return .Error(error)
        }
        
        return super.subscribe(observer)
    }
}

public func << <E>(variable: Variable<E>, element: E) {
    variable.on(.Next(Box(element)))
}