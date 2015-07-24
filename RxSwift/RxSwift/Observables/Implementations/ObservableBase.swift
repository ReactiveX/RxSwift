//
//  ObservableBase.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public class ObservableBase<Element> : Observable<Element> {
    
    override public func subscribe<O : ObserverType where O.Element == Element>(observer: O) -> Disposable {
        let autoDetachObserver = AutoDetachObserver(observer: observer)
        
        let disposable = subscribeCore(ObserverOf(autoDetachObserver))
        autoDetachObserver.setDisposable(disposable)
        
        return autoDetachObserver
    }
    
    func subscribeCore(observer: ObserverOf<Element>) -> Disposable {
        return abstractMethod()
    }
}