//
//  UIControl+Rx.swift
//  RxCocoa
//
//  Created by Daniel Tartaglia on 5/23/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import UIKit

extension UIControl {
    public var rx_enabled: ObserverOf<Bool> {
        return ObserverOf { [weak self] event in
            MainScheduler.ensureExecutingOnScheduler()
            
            switch event {
            case .Next(let value):
                self?.enabled = value
            case .Error(let error):
                bindingErrorToInterface(error)
                break
            case .Completed:
                break
            }
        }
    }
    
    public func rx_controlEvents(controlEvents: UIControlEvents) -> ControlEvent<Void> {
        let source: Observable<Void> = AnonymousObservable { observer in
            MainScheduler.ensureExecutingOnScheduler()
            
            let controlTarget = ControlTarget(control: self, controlEvents: controlEvents) {
                control in
                observer.on(.Next())
            }
            
            return AnonymousDisposable {
                controlTarget.dispose()
            }
        }.takeUntil(rx_deallocated)
        
        return ControlEvent(source: source)
    }
    
    func rx_value<T>(getter getter: () -> T, setter: T -> Void) -> ControlProperty<T> {
        let source: Observable<T> = AnonymousObservable { observer in
            
            observer.on(.Next(getter()))
            
            let controlTarget = ControlTarget(control: self, controlEvents: UIControlEvents.EditingChanged.union(.ValueChanged)) { control in
                observer.on(.Next(getter()))
            }
            
            return AnonymousDisposable {
                controlTarget.dispose()
            }
        }.takeUntil(rx_deallocated)
        
        return ControlProperty<T>(source: source, observer: ObserverOf { event in
            MainScheduler.ensureExecutingOnScheduler()
            
            switch event {
            case .Next(let value):
                setter(value)
            case .Error(let error):
                bindingErrorToInterface(error)
                break
            case .Completed:
                break
            }
        })
    }

}
