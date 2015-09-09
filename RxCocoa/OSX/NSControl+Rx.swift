//
//  NSControl+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 5/31/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import Cocoa
#if !RX_NO_MODULE
import RxSwift
#endif

extension NSControl {
    
    /**
    Reactive wrapper for control event.
    */
    public var rx_controlEvents: ControlEvent<Void> {
        let source: Observable<Void> = AnonymousObservable { observer in
            MainScheduler.ensureExecutingOnScheduler()
            
            let observer = ControlTarget(control: self) { control in
                observer.on(.Next())
            }
            
            return observer
        }.takeUntil(rx_deallocated)
        
        return ControlEvent(source: source)
    }
    
    func rx_value<T>(getter getter: () -> T, setter: T -> Void) -> ControlProperty<T> {
        let source: Observable<T> = AnonymousObservable { observer in
            observer.on(.Next(getter()))
            
            let observer = ControlTarget(control: self) { control in
                observer.on(.Next(getter()))
            }
            
            return observer
        }.takeUntil(rx_deallocated)
        
        return ControlProperty(source: source, observer: ObserverOf { event in
            switch event {
            case .Next(let value):
                setter(value)
            case .Error(let error):
                bindingErrorToInterface(error)
            case .Completed:
                break
            }
        })
    }
    
}