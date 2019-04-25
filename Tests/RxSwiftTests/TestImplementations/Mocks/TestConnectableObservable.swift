//
//  TestConnectableObservable.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift

final class TestConnectableObservable<S: SubjectType> : ConnectableObservableType where S.Element == S.Observer.Element {
    typealias Element = S.Element

    let _o: ConnectableObservable<S.Element>
    
    init(o: Observable<S.Element>, s: S) {
        _o = o.multicast(s)
    }
    
    func connect() -> Disposable {
        return _o.connect()
    }
    
    func subscribe<O : ObserverType>(_ observer: O) -> Disposable where O.Element == Element {
        return _o.subscribe(observer)
    }
}
