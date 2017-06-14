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

    /// Reactive wrapper for `state` property`.
    public var state: ControlProperty<Int> {
        return NSButton.rx.value(
            base,
            getter: { control in
                #if swift(>=4.0)
                    return control.state.rawValue
                #else
                    return control.state
                #endif
            }, setter: { (control: NSButton, state: Int) in
                #if swift(>=4.0)
                    control.state = NSControl.StateValue(rawValue: state)
                #else
                    control.state = state
                #endif
            }
        )
    }
}

#endif
