//
//  NSView+Rx.swift
//  Rx
//
//  Created by Krunoslav Zaher on 12/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import Cocoa
#if !RX_NO_MODULE
import RxSwift
#endif

extension Reactive where Base: NSView {
    /**
     Bindable sink for `hidden` property.
     */
    public var hidden: AnyObserver<Bool> {
        return UIBindingObserver(UIElement: self.base) { view, value in
            view.isHidden = value
        }.asObserver()
    }

    /**
     Bindable sink for `alphaValue` property.
     */
    public var alpha: AnyObserver<CGFloat> {
        return UIBindingObserver(UIElement: self.base) { view, value in
            view.alphaValue = value
        }.asObserver()
    }
}
