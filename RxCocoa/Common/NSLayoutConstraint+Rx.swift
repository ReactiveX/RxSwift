//
//  NSLayoutConstraint+Rx.swift
//  Rx
//
//  Created by Krunoslav Zaher on 12/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

#if os(OSX)
import Cocoa
#else
import UIKit
#endif

#if !RX_NO_MODULE
import RxSwift
#endif

#if os(iOS) || os(OSX) || os(tvOS)
extension NSLayoutConstraint {
    /**
     Bindable sink for `constant` property.
     */
    public var rx_constant: AnyObserver<CGFloat> {
        return UIBindingObserver(UIElement: self) { constraint, constant in
            constraint.constant = constant
        }.asObserver()
    }
    
    /**
     Bindable sink for `active` property.
     */
    @available(iOS 8, OSX 10.10, *)
    public var rx_active: AnyObserver<Bool> {
        return UIBindingObserver(UIElement: self) { constraint, value in
            constraint.active = value
        }.asObserver()
    }
}

#endif
