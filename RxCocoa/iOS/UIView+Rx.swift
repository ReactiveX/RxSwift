//
//  UIView+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 12/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif

extension Reactive where Base: UIView {
    /// Bindable sink for `hidden` property.
    public var isHidden: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { view, hidden in
            view.isHidden = hidden
        }
    }

    /// Bindable sink for `alpha` property.
    public var alpha: UIBindingObserver<Base, CGFloat> {
        return UIBindingObserver(UIElement: self.base) { view, alpha in
            view.alpha = alpha
        }
    }

    /// Bindable sink for `isUserInteractionEnabled` property.
    public var isUserInteractionEnabled: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { view, userInteractionEnabled in
            view.isUserInteractionEnabled = userInteractionEnabled
        }
    }
    
}

#endif
