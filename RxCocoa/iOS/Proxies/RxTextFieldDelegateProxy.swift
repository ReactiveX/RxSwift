//
//  RxTextFieldDelegateProxy.swift
//  RxCocoa
//
//  Created by yoshik on 2017/07/08.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)
    
import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif

/// For more information take a look at `DelegateProxyType`.
public class RxTextFieldDelegateProxy
    : DelegateProxy
    , DelegateProxyType
    , UITextFieldDelegate {
    
    /// For more information take a look at `DelegateProxyType`.
    public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let textField: UITextField = castOrFatalError(object)
        return textField.delegate
    }
    
    /// For more information take a look at `DelegateProxyType`.
    public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let textField: UITextField = castOrFatalError(object)
        textField.delegate = castOptionalOrFatalError(delegate)
    }
    
    // MARK: Delegate proxy methods
    
    #if os(iOS)
    /// For more information take a look at `DelegateProxyType`.
    public override class func createProxyForObject(_ object: AnyObject) -> AnyObject {
        let textField: UITextField = castOrFatalError(object)
        return textField.createRxDelegateProxy()
    }
    #endif
    
    }
    
#endif
