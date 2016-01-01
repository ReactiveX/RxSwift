//
//  NSControl+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 5/31/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import Cocoa
#if !RX_NO_MODULE
import RxSwift
#endif

var rx_value_key: UInt8 = 0
var rx_control_events_key: UInt8 = 0

extension NSControl {

    /**
    Reactive wrapper for control event.
    */
    public var rx_controlEvent: ControlEvent<Void> {
        MainScheduler.ensureExecutingOnScheduler()

        let source = rx_lazyInstanceObservable(&rx_control_events_key) { () -> Observable<Void> in
            Observable.create { [weak self] observer in
                MainScheduler.ensureExecutingOnScheduler()

                guard let control = self else {
                    observer.on(.Completed)
                    return NopDisposable.instance
                }

                let observer = ControlTarget(control: control) { control in
                    observer.on(.Next())
                }
                
                return observer
            }.takeUntil(self.rx_deallocated)
        }
        
        return ControlEvent(events: source)
    }

    /**
    Helper to make sure that `Observable` returned from `createCachedObservable` is only created once.
    This is important because on OSX there is only one `target` and `action` properties on `NSControl`.
    */
    func rx_lazyInstanceObservable<T: AnyObject>(key: UnsafePointer<Void>, createCachedObservable: () -> T) -> T {
        if let value = objc_getAssociatedObject(self, key) {
            return value as! T
        }

        let observable = createCachedObservable()

        objc_setAssociatedObject(self, key, observable, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        return observable
    }

    func rx_value<T: Equatable>(getter getter: () -> T, setter: T -> Void) -> ControlProperty<T> {
        MainScheduler.ensureExecutingOnScheduler()

        let source = rx_lazyInstanceObservable(&rx_value_key) { () -> Observable<T> in
            return Observable.create { [weak self] observer in
                guard let control = self else {
                    observer.on(.Completed)
                    return NopDisposable.instance
                }

                observer.on(.Next(getter()))

                let observer = ControlTarget(control: control) { control in
                    observer.on(.Next(getter()))
                }
                
                return observer
            }
                .distinctUntilChanged()
                .takeUntil(self.rx_deallocated)
        }


        return ControlProperty(values: source, valueSink: AnyObserver { event in
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
}