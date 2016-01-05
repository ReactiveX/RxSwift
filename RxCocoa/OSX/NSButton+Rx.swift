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
        return rx_value(getter: { [weak self] in
            return self?.state ?? 0
        }, setter: { [weak self] state in
            self?.state = state
        })
    }
}