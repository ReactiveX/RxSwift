//
//  RxTextViewDelegateProxy.swift
//  Rx
//
//  Created by Junior B. on 21/06/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation
import Cocoa
#if !RX_NO_MODULE
    import RxSwift
#endif

/**
 Delegate proxy for `NSTextView`.
 
 For more information take a look at `DelegateProxyType`.
 */
public class RxTextViewDelegateProxy
    : DelegateProxy
    , NSTextViewDelegate
, DelegateProxyType {
    
    public let textSubject = PublishSubject<NSAttributedString>()
    
    /**
     Typed parent object.
     */
    public weak private(set) var textView: NSTextView?
    
    /**
     Initializes `RxTextViewDelegateProxy`
     
     - parameter parentObject: Parent object for delegate proxy.
     */
    public required init(parentObject: AnyObject) {
        self.textView = (parentObject as! NSTextView)
        super.init(parentObject: parentObject)
    }
    
    // MARK: Delegate methods
    
    public override func controlTextDidChange(notification: NSNotification) {
        let textView = notification.object as! NSTextView
        let nextValue = textView.attributedString()
        self.textSubject.on(.Next(nextValue))
    }
    
    // MARK: Delegate proxy methods
    
    /**
     For more information take a look at `DelegateProxyType`.
     */
    public override class func createProxyForObject(object: AnyObject) -> AnyObject {
        let control = (object as! NSTextField)
        
        return castOrFatalError(control.rx_createDelegateProxy())
    }
    
    /**
     For more information take a look at `DelegateProxyType`.
     */
    public class func currentDelegateFor(object: AnyObject) -> AnyObject? {
        let textField: NSTextField = castOrFatalError(object)
        return textField.delegate
    }
    
    /**
     For more information take a look at `DelegateProxyType`.
     */
    public class func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
        let textField: NSTextField = castOrFatalError(object)
        textField.delegate = castOptionalOrFatalError(delegate)
    }
}