//
//  UIActivityIndicatorView+Rx.swift
//  Rx
//
//  Created by Ivan Persidskiy on 02/12/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)
import UIKit

#if !RX_NO_MODULE
import RxSwift
#endif

extension UIActivityIndicatorView {

    /**
    Bindable sink for `startAnimating()`, `stopAnimating()` methods.
    */
    public var rx_animating: AnyObserver<Bool> {
        return AnyObserver {event in
            MainScheduler.ensureExecutingOnScheduler()

            switch (event) {
            case .Next(let value):
                if value {
                    self.startAnimating()
                } else {
                    self.stopAnimating()
                }
            case .Error(let error):
                bindingErrorToInterface(error)
            case .Completed:
                break
            }
        }
    }

}

#endif
