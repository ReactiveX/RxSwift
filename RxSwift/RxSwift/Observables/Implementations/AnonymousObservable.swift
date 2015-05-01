//
//  AnonymousObservable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public class AnonymousObservable<Element> : ObservableBase<Element> {
    typealias SubscribeHandler = (ObserverOf<Element>) -> Disposable
   
    let subscribeHandler: SubscribeHandler
    
    public init(_ subscribeHandler: SubscribeHandler) {
        self.subscribeHandler = subscribeHandler
    }
    
    public override func subscribeCore(observer: ObserverOf<Element>) -> Disposable {
        return subscribeHandler(observer)
    }
}