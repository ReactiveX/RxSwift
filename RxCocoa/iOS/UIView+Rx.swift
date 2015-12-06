//
//  UIView+Rx.swift
//  RxCocoa
//
//  Created by Eduardo Barrenechea on 2015-12-06.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import UIKit

extension UIView {

    /**
     Bindable sink for `hidden` property.
     */
    public var rx_hidden: AnyObserver<Bool> {
        return AnyObserver { [weak self] event in
            MainScheduler.ensureExecutingOnScheduler()

            switch event {
            case .Next(let value):
                self?.hidden = value
            case .Error(let error):
                bindingErrorToInterface(error)
                break
            case .Completed:
                break
            }
        }
    }
    
}

#endif
