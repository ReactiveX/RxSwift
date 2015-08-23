//
//  Zip.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 5/23/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

protocol ZipSinkProtocol : class
{
    func next(index: Int)
    func fail(error: ErrorType)
    func done(index: Int)
}

class ZipSink<O: ObserverType> : Sink<O>, ZipSinkProtocol {
    typealias Element = O.E
    
    let arity: Int
    
    let lock = NSRecursiveLock()
    
    // state
    var isDone: [Bool]
    
    init(arity: Int, observer: O, cancel: Disposable) {
        self.isDone = [Bool](count: arity, repeatedValue: false)
        self.arity = arity
        
        super.init(observer: observer, cancel: cancel)
    }

    func getResult() throws -> Element {
        return abstractMethod()
    }
    
    func hasElements(index: Int) -> Bool {
        return abstractMethod()
    }
    
    func next(index: Int) {
        var hasValueAll = true
        
        for i in 0 ..< arity {
            if !hasElements(i) {
                hasValueAll = false;
                break;
            }
        }
        
        if hasValueAll {
            do {
                let result = try getResult()
                self.observer?.on(.Next(result))
            }
            catch let e {
                self.observer?.on(.Error(e))
                dispose()
            }
        }
        else {
            var allOthersDone = true
            
            let arity = self.isDone.count
            for var i = 0; i < arity; ++i {
                if i != index && !isDone[i] {
                    allOthersDone = false
                    break
                }
            }
            
            if allOthersDone {
                observer?.on(.Completed)
                self.dispose()
            }
        }
    }
    
    func fail(error: ErrorType) {
        observer?.on(.Error(error))
        dispose()
    }
    
    func done(index: Int) {
        isDone[index] = true
        
        var allDone = true
        
        for done in self.isDone {
            if !done {
                allDone = false
                break
            }
        }
        
        if allDone {
            observer?.on(.Completed)
            dispose()
        }
    }
}

class ZipObserver<ElementType> : ObserverType {
    typealias E = ElementType
    typealias ValueSetter = (ElementType) -> ()

    var parent: ZipSinkProtocol?
    
    let lock: NSRecursiveLock
    let index: Int
    let this: Disposable
    let setNextValue: ValueSetter
    
    init(lock: NSRecursiveLock, parent: ZipSinkProtocol, index: Int, setNextValue: ValueSetter, this: Disposable) {
        self.lock = lock
        self.parent = parent
        self.index = index
        self.this = this
        self.setNextValue = setNextValue
    }
    
    func on(event: Event<E>) {
       
        if let _ = parent {
            switch event {
            case .Next(_):
                break
            case .Error(_):
                this.dispose()
            case .Completed:
                this.dispose()
            }
        }
        
        lock.performLocked {
            if let parent = parent {
                switch event {
                case .Next(let value):
                    setNextValue(value)
                    parent.next(index)
                case .Error(let error):
                    parent.fail(error)
                case .Completed:
                    parent.done(index)
                }
            }
        }
    }
}
