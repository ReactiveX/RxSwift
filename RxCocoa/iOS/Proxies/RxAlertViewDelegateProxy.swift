//
//  RxAlertViewDelegateProxy.swift
//  RxCocoa
//
//  Created by Carlos García on 8/7/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)

import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif

@available(*, deprecated=2.0.0, message="This class is deprecated by Apple. Removing official support.")
class RxAlertViewDelegateProxy : DelegateProxy
                                 , UIAlertViewDelegate
                                 , DelegateProxyType {

    class func currentDelegateFor(object: AnyObject) -> AnyObject? {
        let alertView: UIAlertView = castOrFatalError(object)
        return alertView.delegate
    }

    class func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
        let alertView: UIAlertView = castOrFatalError(object)
        alertView.delegate = castOptionalOrFatalError(delegate)
    }
}

#endif

