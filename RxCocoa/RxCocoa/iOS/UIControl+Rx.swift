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
    public func rx_controlEvents(controlEvents: UIControlEvents) -> Observable<Void> {
        return AnonymousObservable { observer in
            MainScheduler.ensureExecutingOnScheduler()
            
            let controlTarget = ControlTarget(control: self, controlEvents: controlEvents) {
                control in
                sendNext(observer, ())
            }
            
            return AnonymousDisposable {
                controlTarget.dispose()
            }
        } >- takeUntil(rx_deallocated)
    }
    
    func rx_value<T>(getValue: () -> T) -> Observable<T> {
        return AnonymousObservable { observer in
            
            sendNext(observer, getValue())
            
            let controlTarget = ControlTarget(control: self, controlEvents: UIControlEvents.EditingChanged | .ValueChanged) { control in
                sendNext(observer, getValue())
            }
            
            return AnonymousDisposable {
                controlTarget.dispose()
            }
        } >- takeUntil(rx_deallocated)
    }

    public func rx_subscribeEnabledTo(source: Observable<Bool>) -> Disposable {
        return source.subscribe(AnonymousObserver { [weak self] event in
            MainScheduler.ensureExecutingOnScheduler()

            switch event {
            case .Next(let boxedValue):
                let value = boxedValue.value
                self?.enabled = value
            case .Error(let error):
#if DEBUG
                    rxFatalError("Binding error to textbox: \(error)")
#endif
                break
            case .Completed:
                break
            }
        })
    }
}
