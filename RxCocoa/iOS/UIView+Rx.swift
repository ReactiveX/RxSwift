//
//  UIView+Rx.swift
//  Rx
//
//  Created by Krunoslav Zaher on 12/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import Foundation
import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif

extension Reactive where Base: UIView {
    /**
     Bindable sink for `hidden` property.
     */
    public var hidden: AnyObserver<Bool> {
        return UIBindingObserver(UIElement: self.base) { view, hidden in
            view.isHidden = hidden
        }.asObserver()
    }

    /**
     Bindable sink for `alpha` property.
     */
    public var alpha: AnyObserver<CGFloat> {
        return UIBindingObserver(UIElement: self.base) { view, alpha in
            view.alpha = alpha
        }.asObserver()
    }
}

#endif
