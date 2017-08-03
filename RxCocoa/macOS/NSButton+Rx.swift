//
//  NSButton+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 5/17/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(macOS)

#if !RX_NO_MODULE
import RxSwift
#endif
import Cocoa

extension Reactive where Base: NSButton {
    
    /// Reactive wrapper for control event.
    public var tap: ControlEvent<Void> {
        return controlEvent
    }

    #if swift(>=4.0)
       /// Reactive wrapper for `state` property`.
        public var state: ControlProperty<NSControl.StateValue> {
            return NSButton.rx.value(
                base,
                getter: { control in
                    return control.state
                }, setter: { (control: NSButton, state: NSControl.StateValue) in
                    control.state = state
                }
            )
        }
    #else
        /// Reactive wrapper for `state` property`.
        public var state: ControlProperty<Int> {
            return NSButton.rx.value(
                base,
                getter: { control in
                    return control.state
                }, setter: { (control: NSButton, state: Int) in
                    control.state = state
                }
            )
        }
    #endif
}

#endif
