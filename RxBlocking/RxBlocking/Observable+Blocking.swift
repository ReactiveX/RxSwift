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

public func toArray<E>(source: Observable<E>)
    -> RxResult<[E]> {
    let condition = NSCondition()
    
    var elements = [E]()
    
    var error: ErrorType?
        
    var ended = false

    source.subscribeSafe(AnonymousObserver { e in
        switch e {
        case .Next(let element):
            elements.append(element.value)
        case .Error(let e):
            error = e
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

public func first<E>(source: Observable<E>)
    -> RxResult<E?> {
    let condition = NSCondition()
    
    var element: E?
    
    var error: ErrorType?
    
    var ended = false
    
    let d = SingleAssignmentDisposable()
    
    d.disposable = source.subscribeSafe(AnonymousObserver { e in
        switch e {
        case .Next(let e):
            if element == nil {
                element = e.value
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

public func last<E>(source: Observable<E>)
    -> RxResult<E?> {
    let condition = NSCondition()
    
    var element: E?
    
    var error: ErrorType?
    
    var ended = false
    
    let d = SingleAssignmentDisposable()
    
    d.disposable = source.subscribeSafe(AnonymousObserver { e in
        switch e {
        case .Next(let e):
            element = e.value
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