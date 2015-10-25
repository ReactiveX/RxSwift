//
//  CombineLatest.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

protocol CombineLatestProtocol : class {
    func next(index: Int)
    func fail(error: ErrorType)
    func done(index: Int)
}

class CombineLatestSink<O: ObserverType> : Sink<O>, CombineLatestProtocol {
    typealias Element = O.E
   
    let lock = NSRecursiveLock()

    private let _arity: Int
    private var _numberOfValues = 0
    private var _numberOfDone = 0
    private var _hasValue: [Bool]
    private var _isDone: [Bool]
   
    init(arity: Int, observer: O, cancel: Disposable) {
        _arity = arity
        _hasValue = [Bool](count: arity, repeatedValue: false)
        _isDone = [Bool](count: arity, repeatedValue: false)
        
        super.init(observer: observer, cancel: cancel)
    }
    
    func getResult() throws -> Element {
        abstractMethod()
    }
    
    func next(index: Int) {
        if !_hasValue[index] {
            _hasValue[index] = true
            _numberOfValues++
        }

        if _numberOfValues == _arity {
            do {
                let result = try getResult()
                observer?.on(.Next(result))
            }
            catch let e {
                observer?.on(.Error(e))
                dispose()
            }
        }
        else {
            var allOthersDone = true

            for var i = 0; i < _arity; ++i {
                if i != index && !_isDone[i] {
                    allOthersDone = false
                    break
                }
            }
            
            if allOthersDone {
                observer?.on(.Completed)
                dispose()
            }
        }
    }
    
    func fail(error: ErrorType) {
        observer?.on(.Error(error))
        dispose()
    }
    
    func done(index: Int) {
        if _isDone[index] {
            return
        }

        _isDone[index] = true
        _numberOfDone++

        if _numberOfDone == _arity {
            observer?.on(.Completed)
            dispose()
        }
    }
}

class CombineLatestObserver<ElementType>
    : ObserverType
    , LockOwnerType
    , SynchronizedOnType {
    typealias Element = ElementType
    typealias ValueSetter = (Element) -> Void
    
    private let _parent: CombineLatestProtocol
    
    let _lock: NSRecursiveLock
    private let _index: Int
    private let _this: Disposable
    private let _setLatestValue: ValueSetter
    
    init(lock: NSRecursiveLock, parent: CombineLatestProtocol, index: Int, setLatestValue: ValueSetter, this: Disposable) {
        _lock = lock
        _parent = parent
        _index = index
        _this = this
        _setLatestValue = setLatestValue
    }
    
    func on(event: Event<Element>) {
        synchronizedOn(event)
    }

    func _synchronized_on(event: Event<Element>) {
        switch event {
        case .Next(let value):
            _setLatestValue(value)
            _parent.next(_index)
        case .Error(let error):
            _this.dispose()
            _parent.fail(error)
        case .Completed:
            _this.dispose()
            _parent.done(_index)
        }
    }
}