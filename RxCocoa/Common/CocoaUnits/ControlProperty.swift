//
//  ControlProperty.swift
//  Rx
//
//  Created by Krunoslav Zaher on 8/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif

public protocol ControlPropertyType : ObservableType, ObserverType {
    func asControlProperty() -> ControlProperty<E>
}

/**
    Unit for `Observable`/`ObservableType` that represents property of UI element.

    It's properties are:

    - it never fails
    - `shareReplay(1)` behavior
        - it's stateful, upon subscription (calling subscribe) last element is immediatelly replayed if it was produced
    - it will `Complete` sequence on control being deallocated
    - it never errors out
    - it delivers events on `MainScheduler.sharedInstance`
*/
public struct ControlProperty<PropertyType> : ControlPropertyType {
    public typealias E = PropertyType
    
    let source: Observable<PropertyType>
    let observer: ObserverOf<PropertyType>
    
    init(source: Observable<PropertyType>, observer: ObserverOf<PropertyType>) {
        self.source = source
        self.observer = observer
    }
    
    public func subscribe<O : ObserverType where O.E == E>(observer: O) -> Disposable {
        return self.source.subscribe(observer)
    }
    
    public func asObservable() -> Observable<E> {
        return self.source
    }
    
    public func asControlProperty() -> ControlProperty<E> {
        return self
    }
 
    public func on(event: Event<E>) {
        switch event {
        case .Error(let error):
            bindingErrorToInterface(error)
        case .Next:
            self.observer.on(event)
        case .Completed:
            self.observer.on(event)
        }
    }
}