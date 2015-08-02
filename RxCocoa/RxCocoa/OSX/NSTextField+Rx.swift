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
    let textField: NSTextField
    let textSubject = ReplaySubject<String>(bufferSize: 1)
    
    required init(parentObject: AnyObject) {
        self.textField = parentObject as! NSTextField
        super.init(parentObject: parentObject)
        sendNext(self.textSubject, self.textField.stringValue)
    }
    
    override func controlTextDidChange(notification: NSNotification) {
        let textField = notification.object as! NSTextField
        let nextValue = textField.stringValue
        sendNext(self.textSubject, nextValue)
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
    public func rx_subscribeTextTo(source: Observable<String>) -> Disposable {
        return source.subscribe(AnonymousObserver { event in
            MainScheduler.ensureExecutingOnScheduler()
            
            switch event {
            case .Next(let boxedValue):
                let value = boxedValue.value
                self.stringValue = value
            case .Error(let error):
                #if DEBUG
                    rxFatalError("Binding error to textbox: \(error)")
                #endif
                break
            case .Completed:
                break
            }
        })
    }
    
    public var rx_delegate: DelegateProxy {
        return proxyForObject(self) as RxTextFieldDelegate
    }
    
    public var rx_text: Observable<String> {
        let delegate = proxyForObject(self) as RxTextFieldDelegate
        
        return delegate.textSubject
    }
}