//
//  UIControl+Rx.swift
//  RxCocoa
//
//  Created by Daniel Tartaglia on 5/23/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(visionOS)

import RxSwift
import UIKit

extension Reactive where Base: UIControl {
    /// Reactive wrapper for target action pattern.
    ///
    /// - parameter controlEvents: Filter for observed event types.
    public func controlEvent(_ controlEvents: UIControl.Event) -> ControlEvent<()> {
        let source: Observable<Void> = Observable.create { [weak control = self.base] observer in
                MainScheduler.ensureRunningOnMainThread()

                guard let control = control else {
                    observer.on(.completed)
                    return Disposables.create()
                }

                return MainScheduler.assumeMainActor(execute: {
                    let controlTarget = ControlTarget(control: control, controlEvents: controlEvents) { _ in
                        observer.on(.next(()))
                    }
                    
                    return Disposables.create(with: controlTarget.dispose)
                })
            }
            .take(until: deallocated)

        return ControlEvent(events: source)
    }

    /// Creates a `ControlProperty` that is triggered by target/action pattern value updates.
    ///
    /// - parameter controlEvents: Events that trigger value update sequence elements.
    /// - parameter getter: Property value getter.
    /// - parameter setter: Property value setter.
    public func controlProperty<T>(
        editingEvents: UIControl.Event,
        getter: @escaping @Sendable @MainActor (Base) -> T,
        setter: @escaping @Sendable @MainActor (Base, T) -> Void
    ) -> ControlProperty<T> {
        let source: Observable<T> = Observable.create { [weak weakControl = base] observer in
                guard let control = weakControl else {
                    observer.on(.completed)
                    return Disposables.create()
                }

                observer.on(.next(MainScheduler.assumeMainActor(execute: { getter(control) })))
                
                return MainScheduler.assumeMainActor(execute: {
                    let controlTarget = ControlTarget(control: control, controlEvents: editingEvents) { [weak weakControl] _ in
                        if let control = weakControl {
                            observer.on(.next(MainScheduler.assumeMainActor(execute: { getter(control) })))
                        }
                    }
                    
                    return Disposables.create(with: controlTarget.dispose)
                })
            }
            .take(until: deallocated)

        let bindingObserver = Binder(base, binding: MainScheduler.assumeMainActor(setter))

        return ControlProperty<T>(values: source, valueSink: bindingObserver)
    }

    /// This is a separate method to better communicate to public consumers that
    /// an `editingEvent` needs to fire for control property to be updated.
    internal func controlPropertyWithDefaultEvents<T>(
        editingEvents: UIControl.Event = [.allEditingEvents, .valueChanged],
        getter: @escaping @Sendable @MainActor (Base) -> T,
        setter: @escaping @Sendable @MainActor (Base, T) -> Void
        ) -> ControlProperty<T> {
        return controlProperty(
            editingEvents: editingEvents,
            getter: getter,
            setter: setter
        )
    }
}

#endif
