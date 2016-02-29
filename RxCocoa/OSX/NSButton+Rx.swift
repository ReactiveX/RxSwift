//
//  NSButton+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 5/17/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import Cocoa

extension NSButton {
    
    /**
    Reactive wrapper for control event.
    */
    public var rx_tap: ControlEvent<Void> {
        return rx_controlEvent
    }

    /**
    Reactive wrapper for `state` property`.
    */
    public var rx_state: ControlProperty<Int> {
        return NSButton.rx_value(
            self,
            getter: { control in
                return control.state
            }, setter: { control, state in
                control.state = state
            }
        )
    }
}