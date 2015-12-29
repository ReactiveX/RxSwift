//
//  TestConnectableObservable.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 4/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

class TestConnectableObservable<S: SubjectType where S.E == S.SubjectObserverType.E> : ConnectableObservableType {
    typealias E = S.E

    let _o: ConnectableObservable<S.E>
    
    init(o: Observable<S.E>, s: S) {
        _o = o.multicast(s)
    }
    
    func connect() -> Disposable {
        return _o.connect()
    }
    
    func subscribe<O : ObserverType where O.E == E>(observer: O) -> Disposable {
        return _o.subscribe(observer)
    }
}