//
//  TestConnectableObservable.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift

final class TestConnectableObservable<S: SubjectType> : ConnectableObservableType where S.E == S.SubjectObserverType.E {
    typealias E = S.E

    let _o: ConnectableObservable<S.E>
    
    init(o: Observable<S.E>, s: S) {
        _o = o.multicast(s)
    }
    
    func connect() -> Disposable {
        return _o.connect()
    }
    
    func subscribe<O : ObserverType>(_ observer: O) -> Disposable where O.E == E {
        return _o.subscribe(observer)
    }
}
