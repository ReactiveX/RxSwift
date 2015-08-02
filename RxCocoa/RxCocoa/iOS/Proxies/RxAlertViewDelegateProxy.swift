//
//  RxAlertViewDelegateProxy.swift
//  RxCocoa
//
//  Created by Carlos García on 8/7/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif

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
