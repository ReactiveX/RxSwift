//
//  Observable+Blocking.swift
//  RxBlocking
//
//  Created by Krunoslav Zaher on 7/12/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif

extension ObservableType {
    
    /**
    This operator blocks the thread until the Observable terminates 
    and then produces an equivalent object or data structure.
    
    - seeAlso: 
    [http://reactivex.io/documentation/operators/to.html](http://reactivex.io/documentation/operators/to.html)
    
    ```Swift
    // This example runs in a Playground
    let source = timer(0, 1000, scheduler: MainScheduler.sharedInstance)
        .take(5)
        .toArray() // not recommended for production code
    
    let subscription = source.get()
    ```
    
    - todo: Improve operator's description @kzaher
    - warning: Use with caution, blocking operators are not meant for production code and are
    mainly designed for Unit Tests usage.
    
    - requires: ObservableType
    - returns: RxResult
    */
    public func toArray() -> RxResult<[E]> {
            
        let condition = NSCondition()
        var elements = [E]()
        var error: ErrorType?
        var ended = false

        self.subscribeSafe(AnonymousObserver { event in
            switch event {
            case .Next(let element):
                elements.append(element)
            case .Error(let element):
                error = element
                condition.lock()
                ended = true
                condition.signal()
                condition.unlock()
            case .Completed:
                condition.lock()
                ended = true
                condition.signal()
                condition.unlock()
            }
        })
        condition.lock()
        while !ended {
            condition.wait()
        }
        condition.unlock()
        
        if let error = error {
            return failure(error)
        }

        return success(elements)
    }
}

extension ObservableType {
    
    public var first: RxResult<E?> {
        let condition = NSCondition()
        
        var element: E?
        
        var error: ErrorType?
        
        var ended = false
        
        let d = SingleAssignmentDisposable()
        
        d.disposable = self.subscribeSafe(AnonymousObserver { event in
            switch event {
            case .Next(let e):
                if element == nil {
                    element = e
                }
                break
            case .Error(let e):
                error = e
            default:
                break
            }
            
            condition.lock()
            ended = true
            condition.signal()
            condition.unlock()
        })
        
        condition.lock()
        while !ended {
            condition.wait()
        }
        d.dispose()
        condition.unlock()
        
        if let error = error {
            return failure(error)
        }
        
        return success(element)
    }
}

extension ObservableType {
    public var last: RxResult<E?> {
        let condition = NSCondition()
        
        var element: E?
        
        var error: ErrorType?
        
        var ended = false
        
        let d = SingleAssignmentDisposable()
        
        d.disposable = self.subscribeSafe(AnonymousObserver { e in
            switch e {
            case .Next(let e):
                element = e
                return
            case .Error(let e):
                error = e
            default:
                break
            }
            
            condition.lock()
            ended = true
            condition.signal()
            condition.unlock()
            })
        
        condition.lock()
        while !ended {
            condition.wait()
        }
        d.dispose()
        condition.unlock()
        
        if let error = error {
            return failure(error)
        }
        
        return success(element)
    }
}