//
//  UIControl+Rx.swift
//  RxCocoa
//
//  Created by Daniel Tartaglia on 5/23/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
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
        return UIBindingObserver(UIElement: self) { control, value in
            control.enabled = value
        }.asObserver()
    }

    /**
     Bindable sink for `selected` property.
     */
    public var rx_selected: AnyObserver<Bool> {
        return UIBindingObserver(UIElement: self) { control, selected in
            control.selected = selected
        }.asObserver()
    }

    /**
    Reactive wrapper for target action pattern.
    
    - parameter controlEvents: Filter for observed event types.
    */
    public func rx_controlEvent(controlEvents: UIControlEvents) -> ControlEvent<Void> {
        let source: Observable<Void> = Observable.create { [weak self] observer in
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
        
        return ControlEvent(events: source)
    }

    /**
     You might be wondering why the ugly `as!` casts etc, well, for some reason if 
     Swift compiler knows C is UIControl type and optimizations are turned on, it will crash.

     Can somebody offer poor Swift compiler writers some other better job maybe, this is becoming
     ridiculous. So much time wasted ...
    */
    static func rx_value<C: AnyObject, T: Equatable>(control: C, getter: (C) -> T, setter: (C, T) -> Void) -> ControlProperty<T> {
        let source: Observable<T> = Observable.create { [weak weakControl = control] observer in
                guard let control = weakControl else {
                    observer.on(.Completed)
                    return NopDisposable.instance
                }

                observer.on(.Next(getter(control)))

                let controlTarget = ControlTarget(control: control as! UIControl, controlEvents: [.AllEditingEvents, .ValueChanged]) { _ in
                    if let control = weakControl {
                        observer.on(.Next(getter(control)))
                    }
                }
                
                return AnonymousDisposable {
                    controlTarget.dispose()
                }
            }
            .distinctUntilChanged()
            .takeUntil((control as! NSObject).rx_deallocated)

        let bindingObserver = UIBindingObserver(UIElement: control, binding: setter)

        return ControlProperty<T>(values: source, valueSink: bindingObserver)
    }

}

#endif
