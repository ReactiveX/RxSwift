//
//  TestConnectableObservable.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift

final class TestConnectableObservable<Subject: SubjectType> : ConnectableObservableType where Subject.Element == Subject.Observer.Element {
    typealias Element = Subject.Element

    let _o: ConnectableObservable<Subject.Element>
    
    init(o: Observable<Subject.Element>, s: Subject) {
        _o = o.multicast(s)
    }
    
    func connect() -> Disposable {
        return _o.connect()
    }
    
    func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        return _o.subscribe(observer)
    }
}
