//
//  UIControl+Rx.swift
//  RxCocoa
//
//  Created by Daniel Tartaglia on 5/23/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import UIKit

extension UIControl {
    
    /**
    Bindable sink for `enabled` property.
    */
    public var rx_enabled: AnyObserver<Bool> {
        return AnyObserver { [weak self] event in
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
    
    /**
    Reactive wrapper for target action pattern.
    
    - parameter controlEvents: Filter for observed event types.
    */
    public func rx_controlEvents(controlEvents: UIControlEvents) -> ControlEvent<Void> {
        let source: Observable<Void> = create { [weak self] observer in
            MainScheduler.ensureExecutingOnScheduler()

            guard let control = self else {
                observer.on(.Completed)
                return NopDisposable.instance
            }

            let controlTarget = ControlTarget(control: control, controlEvents: controlEvents) {
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
        let source: Observable<T> = create { [weak self] observer in
            guard let control = self else {
                observer.on(.Completed)
                return NopDisposable.instance
            }

            observer.on(.Next(getter()))

            let controlTarget = ControlTarget(control: control, controlEvents: [.EditingChanged, .ValueChanged]) { control in
                observer.on(.Next(getter()))
            }
            
            return AnonymousDisposable {
                controlTarget.dispose()
            }
        }.takeUntil(rx_deallocated)
        
        return ControlProperty<T>(source: source, observer: AnyObserver { event in
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

#endif
