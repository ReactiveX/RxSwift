//
//  Producer.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/20/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

class Producer<Element> : Observable<Element> {
    override init() {
        super.init()
    }

    override func subscribe<O : ObserverType>(_ observer: O) -> Disposable where O.E == Element {
        
    }

    func run<O : ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == Element {
        rxAbstractMethod()
    }
}

