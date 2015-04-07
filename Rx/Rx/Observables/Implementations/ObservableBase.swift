//
//  ObservableBase.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public class ObservableBase<Element> : Observable<Element> {
    
    override public func subscribe(observer: ObserverOf<Element>) -> Result<Disposable> {
        let autoDetachObserver = AutoDetachObserver(observer: observer)
        
        return subscribeCore(ObserverOf(autoDetachObserver)) >== { disposable in
            autoDetachObserver.setDisposable(disposable)
            return success(disposable)
        }
    }
    
    func subscribeCore(observer: ObserverOf<Element>) -> Result<Disposable> {
        return abstractMethod()
    }
}