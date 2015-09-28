//
//  RxActionSheetDelegateProxy.swift
//  RxCocoa
//
//  Created by Carlos García on 8/7/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)

import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif

class RxActionSheetDelegateProxy : DelegateProxy
                                 , UIActionSheetDelegate
                                 , DelegateProxyType {
    
    class func currentDelegateFor(object: AnyObject) -> AnyObject? {
        let actionSheet: UIActionSheet = castOrFatalError(object)
        return actionSheet.delegate
    }
    
    class func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
        let actionSheet: UIActionSheet = castOrFatalError(object)
        actionSheet.delegate = castOptionalOrFatalError(delegate)
    }
}

#endif
