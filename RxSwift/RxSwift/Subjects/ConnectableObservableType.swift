//
//  ConnectableObservableType.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/1/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public class ConnectableObservableType<Element>: Observable<Element> {
    public override init() {
        
    }
    
    public func connect() -> Disposable {
        return abstractMethod()
    }
}