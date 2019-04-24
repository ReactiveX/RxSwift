//
//  MySubject.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/18/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift

final class MySubject<Element> : SubjectType, ObserverType where Element : Hashable {
    typealias SubjectObserverType = MySubject<Element>

    var _disposeOn: [Element : Disposable] = [:]
    var _observer: AnyObserver<Element>! = nil
    var _subscribeCount: Int = 0
    var _isDisposed: Bool = false
    
    var subscribeCount: Int {
        return _subscribeCount
    }
    
    var isDisposed: Bool {
        return _isDisposed
    }
    
    func disposeOn(_ value: Element, disposable: Disposable) {
        _disposeOn[value] = disposable
    }
    
    func on(_ event: Event<Element>) {
        _observer.on(event)
        switch event {
        case .next(let value):
            if let disposable = _disposeOn[value] {
                disposable.dispose()
            }
        default: break
        }
    }
    
    func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        _subscribeCount += 1
        _observer = AnyObserver(observer)
        
        return Disposables.create {
            self._observer = AnyObserver { _ -> Void in () }
            self._isDisposed = true
        }
    }

    func asObserver() -> MySubject<Element> {
        return self
    }
}
