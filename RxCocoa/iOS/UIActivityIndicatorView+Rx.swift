//
//  UIActivityIndicatorView+Rx.swift
//  RxCocoa
//
//  Created by Ivan Persidskiy on 02/12/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)
import UIKit

#if !RX_NO_MODULE
import RxSwift
#endif

extension Reactive where Base: UIActivityIndicatorView {

    /**
    Bindable sink for `startAnimating()`, `stopAnimating()` methods.
    */
    public var animating: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { activityIndicator, active in
            if active {
                activityIndicator.startAnimating()
            } else {
                activityIndicator.stopAnimating()
            }
        }
    }

}

#endif
