//
//  ConnectableObservable.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 4/19/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

class ConnectableObservable<Element> : ConnectableObservableType<Element> {
    let _o: ConnectableObservableType<Element>
    
    init(o: Observable<Element>, s: SubjectType<Element, Element>) {
        _o = o >- multicast(s)
        super.init()
    }
    
    override func connect() -> Disposable {
        return _o.connect()
    }
    
    override func subscribe<O : ObserverType where O.Element == Element>(observer: O) -> Disposable {
        return _o.subscribe(observer)
    }
}