//
//  CombineLatest.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

protocol CombineLatestProtocol : class {
    func next(index: Int)
    func fail(error: ErrorProtocol)
    func done(index: Int)
}

class CombineLatestSink<O: ObserverType>
    : Sink<O>
    , CombineLatestProtocol {
    typealias Element = O.E
   
    let _lock = RecursiveLock()

    private let _arity: Int
    private var _numberOfValues = 0
    private var _numberOfDone = 0
    private var _hasValue: [Bool]
    private var _isDone: [Bool]
   
    init(arity: Int, observer: O) {
        _arity = arity
        _hasValue = [Bool](repeating: false, count: arity)
        _isDone = [Bool](repeating: false, count: arity)
        
        super.init(observer: observer)
    }
    
    func getResult() throws -> Element {
        abstractMethod()
    }
    
    func next(index: Int) {
        if !_hasValue[index] {
            _hasValue[index] = true
            _numberOfValues += 1
        }

        if _numberOfValues == _arity {
            do {
                let result = try getResult()
                forwardOn(event: .Next(result))
            }
            catch let e {
                forwardOn(event: .Error(e))
                dispose()
            }
        }
        else {
            var allOthersDone = true

            for i in 0 ..< _arity {
                if i != index && !_isDone[i] {
                    allOthersDone = false
                    break
                }
            }
            
            if allOthersDone {
                forwardOn(event: .Completed)
                dispose()
            }
        }
    }
    
    func fail(error: ErrorProtocol) {
        forwardOn(event: .Error(error))
        dispose()
    }
    
    func done(index: Int) {
        if _isDone[index] {
            return
        }

        _isDone[index] = true
        _numberOfDone += 1

        if _numberOfDone == _arity {
            forwardOn(event: .Completed)
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
    
    let _lock: RecursiveLock
    private let _index: Int
    private let _this: Disposable
    private let _setLatestValue: ValueSetter
    
    init(lock: RecursiveLock, parent: CombineLatestProtocol, index: Int, setLatestValue: ValueSetter, this: Disposable) {
        _lock = lock
        _parent = parent
        _index = index
        _this = this
        _setLatestValue = setLatestValue
    }
    
    func on(event: Event<Element>) {
        synchronizedOn(event: event)
    }

    func _synchronized_on(event: Event<Element>) {
        switch event {
        case .Next(let value):
            _setLatestValue(value)
            _parent.next(index: _index)
        case .Error(let error):
            _this.dispose()
            _parent.fail(error: error)
        case .Completed:
            _this.dispose()
            _parent.done(index: _index)
        }
    }
}
