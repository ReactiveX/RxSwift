//
//  MySubject.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 4/18/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

class MySubject<Element where Element : Hashable> : Observable<Element>, SubjectType, ObserverType {
    typealias SubjectObserverType = MySubject<E>

    var _disposeOn: [Element : Disposable] = [:]
    var _observer: ObserverOf<Element>! = nil
    var _subscribeCount: Int = 0
    var _disposed: Bool = false
    
    override init() {
        super.init()
    }
    
    var subscribeCount: Int {
        get {
            return _subscribeCount
        }
    }
    
    var diposed: Bool {
        get {
            return _disposed
        }
    }
    
    func disposeOn(value: Element, disposable: Disposable) {
        _disposeOn[value] = disposable
    }
    
    func on(event: Event<E>) {
        _observer.on(event)
        switch event {
        case .Next(let value):
            if let disposable = _disposeOn[value] {
                disposable.dispose()
            }
        default: break
        }
    }
    
    override func subscribe<O : ObserverType where O.E == E>(observer: O) -> Disposable {
        _subscribeCount++
        _observer = ObserverOf(observer)
        
        return AnonymousDisposable {
            self._observer = ObserverOf { _ -> Void in () }
            self._disposed = true
        }
    }

    func asObserver() -> MySubject<E> {
        return self
    }
}