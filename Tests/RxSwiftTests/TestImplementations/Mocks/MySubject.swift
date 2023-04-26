//
//  MySubject.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/18/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift

final class MySubject<Element> : SubjectType, ObserverType where Element: Hashable {
    typealias SubjectObserverType = MySubject<Element>

    var disposeOn: [Element : Disposable] = [:]
    var observer: AnyObserver<Element>! = nil
    var subscriptionCount: Int = 0
    var disposed: Bool = false
    
    var subscribeCount: Int { subscriptionCount }
    var isDisposed: Bool { disposed }
    
    func disposeOn(_ value: Element, disposable: Disposable) {
        self.disposeOn[value] = disposable
    }
    
    func on(_ event: Event<Element>) {
        self.observer.on(event)
        switch event {
        case .next(let value):
            if let disposable = self.disposeOn[value] {
                disposable.dispose()
            }
        default: break
        }
    }
    
    func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        self.subscriptionCount += 1
        self.observer = AnyObserver(observer)
        
        return Disposables.create {
            self.observer = AnyObserver { _ -> Void in () }
            self.disposed = true
        }
    }

    func asObserver() -> MySubject<Element> {
        self
    }
}
