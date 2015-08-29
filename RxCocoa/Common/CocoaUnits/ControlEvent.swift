//
//  ControlEvent.swift
//  Rx
//
//  Created by Krunoslav Zaher on 8/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif

protocol ControlEventType : ObservableType {
    typealias E
    func asControlEvent() -> ControlEvent<E>
}

/**
    Unit for `Observable`/`ObservableType` that represents event on UI element.

    It's properties are:

    - it never fails
    - it won't send any initial value on subscription
    - it will `Complete` sequence on control being deallocated
    - it never errors out
    - it delivers events on `MainScheduler.sharedInstance`
*/
public struct ControlEvent<PropertyType> : ControlEventType {
    public typealias E = PropertyType
    
    let source: Observable<PropertyType>
    
    init(source: Observable<PropertyType>) {
        self.source = source
    }
    
    public func subscribe<O : ObserverType where O.E == E>(observer: O) -> Disposable {
        return self.source.subscribe(observer)
    }
    
    public func asObservable() -> Observable<E> {
        return self.source
    }
    
    public func asControlEvent() -> ControlEvent<E> {
        return self
    }
}