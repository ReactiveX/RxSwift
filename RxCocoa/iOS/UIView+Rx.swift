//
//  UIView+Rx.swift
//  RxCocoa
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
    public var hidden: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { view, hidden in
            view.isHidden = hidden
        }
    }

    /**
     Bindable sink for `alpha` property.
     */
    public var alpha: UIBindingObserver<Base, CGFloat> {
        return UIBindingObserver(UIElement: self.base) { view, alpha in
            view.alpha = alpha
        }
    }
}

#endif
