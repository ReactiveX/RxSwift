//
//  NSTextField+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 5/17/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import Cocoa
#if !RX_NO_MODULE
import RxSwift
#endif

/**
 Delegate proxy for `NSTextField`.

 For more information take a look at `DelegateProxyType`.
*/
public class RxTextFieldDelegateProxy
    : DelegateProxy
    , NSTextFieldDelegate
    , DelegateProxyType {

    private let textSubject = PublishSubject<String>()

    /**
     Typed parent object.
    */
    public weak private(set) var textField: NSTextField?

    /**
     Initializes `RxTextFieldDelegateProxy`
     
     - parameter parentObject: Parent object for delegate proxy.
    */
    public required init(parentObject: AnyObject) {
        self.textField = (parentObject as! NSTextField)
        super.init(parentObject: parentObject)
    }

    // MARK: Delegate methods

    public override func controlTextDidChange(notification: NSNotification) {
        let textField = notification.object as! NSTextField
        let nextValue = textField.stringValue
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

extension NSTextField {

    /**
    Factory method that enables subclasses to implement their own `rx_delegate`.

     - returns: Instance of delegate proxy that wraps `delegate`.
     */
    public func rx_createDelegateProxy() -> RxTextFieldDelegateProxy {
        return RxTextFieldDelegateProxy(parentObject: self)
    }

    /**
    Reactive wrapper for `delegate`.
    
    For more information take a look at `DelegateProxyType` protocol documentation.
    */
    public var rx_delegate: DelegateProxy {
        return proxyForObject(RxTextFieldDelegateProxy.self, self)
    }
    
    /**
    Reactive wrapper for `text` property.
    */
    public var rx_text: ControlProperty<String> {
        let delegate = proxyForObject(RxTextFieldDelegateProxy.self, self)
        
        let source = Observable.deferred { [weak self] in
            delegate.textSubject.startWith(self?.stringValue ?? "")
        }.takeUntil(rx_deallocated)

        let observer = UIBindingObserver(UIElement: self) { control, value in
            control.stringValue = value
        }

        return ControlProperty(values: source, valueSink: observer.asObserver())
    }
    
}
