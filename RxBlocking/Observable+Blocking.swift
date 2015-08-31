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
    public func toArray() throws -> [E] {
        let condition = NSCondition()
        
        var elements = [E]()
        
        var error: ErrorType?
            
        var ended = false

        self.subscribeSafe(AnonymousObserver { e in
            switch e {
            case .Next(let element):
                elements.append(element)
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
            throw error
        }

        return elements
    }
}

extension ObservableType {
    public func first() throws -> E? {
        let condition = NSCondition()
        
        var element: E?
        
        var error: ErrorType?
        
        var ended = false
        
        let d = SingleAssignmentDisposable()
        
        d.disposable = self.subscribeSafe(AnonymousObserver { e in
            switch e {
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
            throw error
        }
        
        return element
    }
}

extension ObservableType {
    public func last() throws -> E? {
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
            throw error
        }
        
        return element
    }
}