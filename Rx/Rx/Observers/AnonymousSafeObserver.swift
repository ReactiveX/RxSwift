//
//  AnonymousSafeObserver.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class AnonymousSafeObserver<ElementType> : ObserverClassType {
    typealias Element = ElementType
    
    typealias State = Bool
    typealias EventHandler = Event<Element> -> Result<Void>
    
    let eventHandler: EventHandler
    let disposable: Disposable
    
    var lock = Lock()
    var stopped: State = false
    
    init(eventHandler: EventHandler, disposable: Disposable) {
        self.eventHandler = eventHandler
        self.disposable = disposable
    }
    
    func on(event: Event<Element>) -> Result<Void> {
        switch event {
        case .Next(let next):
            // TODO: in general case where next values could come from any thread
            // this is direct port from Rx
            // this looks like wrong logic, but for most cases this will work
            if stopped {
               return SuccessResult
            }
            
            let nextResult = eventHandler(event)
            
            return nextResult >>! { e in
                self.disposable.dispose()
                return .Error(e)
            }
        case .Error: fallthrough
        case .Completed:
            var stopped: Bool = lock.calculateLocked {
                var stopped = self.stopped;
                self.stopped = true;
                return stopped
            }
            
            if !stopped {
                let result = self.eventHandler(event)
                self.disposable.dispose()
                return result
            }
            
            return SuccessResult
        }
    }
}