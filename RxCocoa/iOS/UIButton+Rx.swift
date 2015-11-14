//
//  UIButton+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import UIKit

extension UIButton {
    
    /**
    Reactive wrapper for `TouchUpInside` control event.
    */
    public var rx_tap: ControlEvent<Void> {
		return rx_controlEvents(.TouchUpInside)
    }
    
}

#endif

#if os(tvOS)

import Foundation
#if !RX_NO_MODULE
    import RxSwift
#endif
import UIKit

extension UIButton {

    /**
     Reactive wrapper for `PrimaryActionTriggered` control event.
     */
    public var rx_primaryAction: ControlEvent<Void> {
        return rx_controlEvents(.PrimaryActionTriggered)
    }
}

#endif
