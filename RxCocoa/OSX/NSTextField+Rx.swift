//
//  NSTextField+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 5/17/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import Cocoa
#if !RX_NO_MODULE
import RxSwift
#endif

class RxTextFieldDelegate : DelegateProxy
                          , NSTextFieldDelegate
                          , DelegateProxyType {
    let textSubject = PublishSubject<String>()
    
    required init(parentObject: AnyObject) {
        let textField = parentObject as! NSTextField
        super.init(parentObject: parentObject)
        self.textSubject.on(.Next(textField.stringValue))
    }
    
    override func controlTextDidChange(notification: NSNotification) {
        let textField = notification.object as! NSTextField
        let nextValue = textField.stringValue
        self.textSubject.on(.Next(nextValue))
    }

    class func currentDelegateFor(object: AnyObject) -> AnyObject? {
        let textField: NSTextField = castOrFatalError(object)
        return textField.delegate
    }
    
    class func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
        let textField: NSTextField = castOrFatalError(object)
        textField.delegate = castOptionalOrFatalError(delegate)
    }
    
}

extension NSTextField {
    
    /**
    Reactive wrapper for `delegate`.
    
    For more information take a look at `DelegateProxyType` protocol documentation.
    */
    public var rx_delegate: DelegateProxy {
        return proxyForObject(self) as RxTextFieldDelegate
    }
    
    /**
    Reactive wrapper for `text` property.
    */
    public var rx_text: ControlProperty<String> {
        let delegate = proxyForObject(self) as RxTextFieldDelegate
        
        let source = deferred { [weak self] in
            delegate.textSubject.startWith(self?.stringValue ?? "")
        }.takeUntil(rx_deallocated)
        
        return ControlProperty(source: source, observer: AnyObserver { [weak self] event in
            MainScheduler.ensureExecutingOnScheduler()
            
            switch event {
            case .Next(let value):
                self?.stringValue = value
            case .Error(let error):
                bindingErrorToInterface(error)
                break
            case .Completed:
                break
            }
        })
    }
    
}
