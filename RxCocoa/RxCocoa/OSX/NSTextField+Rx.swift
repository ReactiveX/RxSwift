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

class RxTextFieldDelegate : NSObject, NSTextFieldDelegate {
    typealias Observer = ObserverOf<String>
    typealias DisposeKey = Bag<Observer>.KeyType
    
    var observers: Bag<Observer> = Bag()
    
    override func controlTextDidChange(notification: NSNotification) {
        let textField = notification.object as! NSTextField
        let nextValue = textField.stringValue
        dispatchNext(nextValue, observers)
    }
    
    func addObserver(observer: Observer) -> DisposeKey {
        MainScheduler.ensureExecutingOnScheduler()
        
        return observers.put(observer)
    }
    
    func removeObserver(key: DisposeKey) {
        MainScheduler.ensureExecutingOnScheduler()
        
        let element = observers.removeKey(key)
        if element == nil {
            removingObserverFailed()
        }
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
    
    public var rx_text: Observable<String> {
        return AnonymousObservable { observer in
            MainScheduler.ensureExecutingOnScheduler()
            
            var maybeDelegate = self.rx_checkDelegate()
            
            if maybeDelegate == nil {
                let delegate = self.rx_delegate()
                maybeDelegate = delegate
                self.delegate = maybeDelegate
            }
            
            let delegate = maybeDelegate!
            
            sendNext(observer, self.stringValue)
            
            let key = delegate.addObserver(observer)
            
            return AnonymousDisposable {
                MainScheduler.ensureExecutingOnScheduler()
                
                _ = self.rx_checkDelegate()
                
                delegate.removeObserver(key)
                
                if delegate.observers.count == 0 {
                    self.delegate = nil
                }
            }
        }
    }
    
    private var rx_delegate: RxTextFieldDelegate {
        return RxTextFieldDelegate()
    }
    
    private var rx_checkDelegate: RxTextFieldDelegate? {
        MainScheduler.ensureExecutingOnScheduler()
        
        if self.delegate == nil {
            return nil
        }
        
        let maybeDelegate = self.delegate as? RxTextFieldDelegate
        
        if maybeDelegate == nil {
            rxFatalError("View already has incompatible delegate set. To use rx observable (for now) please remove earlier delegate registration.")
        }
        
        return maybeDelegate!
    }
}