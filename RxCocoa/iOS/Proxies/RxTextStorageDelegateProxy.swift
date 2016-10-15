//
//  RxTextStorageDelegateProxy.swift
//  RxCocoa
//
//  Created by Segii Shulga on 12/30/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)
    
    import Foundation
#if !RX_NO_MODULE
    import RxSwift
#endif
    import UIKit
    
public class RxTextStorageDelegateProxy
    : DelegateProxy
    , DelegateProxyType
    , NSTextStorageDelegate {
    
    
    /**
     For more information take a look at `DelegateProxyType`.
     */
    public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let textStorage: NSTextStorage = castOrFatalError(object)
        textStorage.delegate = castOptionalOrFatalError(delegate)
    }
    
    /**
     For more information take a look at `DelegateProxyType`.
     */
    public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let textStorage: NSTextStorage = castOrFatalError(object)
        return textStorage.delegate
    }


}
#endif
