//
//  ObservableBase.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public class ObservableBase<Element> : Observable<Element> {
    
    override public func subscribe(observer: ObserverOf<Element>) -> Disposable {
        let autoDetachObserver = AutoDetachObserver(observer: observer)
        
        let disposable = subscribeCore(ObserverOf(autoDetachObserver))
        autoDetachObserver.setDisposable(disposable)
        return disposable
    }
    
    func subscribeCore(observer: ObserverOf<Element>) -> Disposable {
        return abstractMethod()
    }
}