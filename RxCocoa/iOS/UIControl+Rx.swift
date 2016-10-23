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

extension Reactive where Base: UIControl {
    
    /// Bindable sink for `enabled` property.
    public var isEnabled: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { control, value in
            control.isEnabled = value
        }
    }

    /// Bindable sink for `selected` property.
    public var isSelected: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { control, selected in
            control.isSelected = selected
        }
    }

    /// Reactive wrapper for target action pattern.
    ///
    /// - parameter controlEvents: Filter for observed event types.
    public func controlEvent(_ controlEvents: UIControlEvents) -> ControlEvent<Void> {
        let source: Observable<Void> = Observable.create { [weak control = self.base] observer in
            MainScheduler.ensureExecutingOnScheduler()

            guard let control = control else {
                observer.on(.completed)
                return Disposables.create()
            }

            let controlTarget = ControlTarget(control: control, controlEvents: controlEvents) {
                control in
                observer.on(.next())
            }
            
            return Disposables.create(with: controlTarget.dispose)
        }.takeUntil(deallocated)

        return ControlEvent(events: source)
    }

    /// You might be wondering why the ugly `as!` casts etc, well, for some reason if
    /// Swift compiler knows C is UIControl type and optimizations are turned on, it will crash.
    static func value<C: NSObject, T>(_ control: C, getter: @escaping (C) -> T, setter: @escaping (C, T) -> Void) -> ControlProperty<T> {
        let source: Observable<T> = Observable.create { [weak weakControl = control] observer in
                guard let control = weakControl else {
                    observer.on(.completed)
                    return Disposables.create()
                }

                observer.on(.next(getter(control)))

                let controlTarget = ControlTarget(control: control as! UIControl, controlEvents: [.allEditingEvents, .valueChanged]) { _ in
                    if let control = weakControl {
                        observer.on(.next(getter(control)))
                    }
                }
                
                return Disposables.create(with: controlTarget.dispose)
            }
            .takeUntil((control as NSObject).rx.deallocated)

        let bindingObserver = UIBindingObserver(UIElement: control, binding: setter)

        return ControlProperty<T>(values: source, valueSink: bindingObserver)
    }

}

#endif
