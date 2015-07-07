//
//  NSTextField+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 5/17/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import Cocoa
import RxSwift

class RxTextFieldDelegate : DelegateProxy
                          , NSTextFieldDelegate
                          , DelegateProxyType {
    typealias Observer = ObserverOf<String>
    typealias DisposeKey = Bag<Observer>.KeyType
    
    var observers: Bag<Observer> = Bag()
    
    let textField: NSTextField
    
    required init(parentObject: AnyObject) {
        self.textField = parentObject as! NSTextField
        super.init(parentObject: parentObject)
    }
    
    override func controlTextDidChange(notification: NSNotification) {
        let textField = notification.object as! NSTextField
        let nextValue = textField.stringValue
        dispatchNext(nextValue, observers)
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
            case .Next(let value):
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
        return proxyObservableForObject(self, addObserver: { (p: RxTextFieldDelegate, o) in
            sendNext(o, self.stringValue)
            return p.observers.put(o)
        }, removeObserver: { p, d in
            p.observers.removeKey(d)
        })
    }
}