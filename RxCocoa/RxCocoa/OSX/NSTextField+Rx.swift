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

extension NSTextField {
    public func rx_subscribeTextTo(source: Observable<String>) -> Disposable {
        return source.subscribe(AnonymousObserver { event in
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
    
    public func rx_text() -> Observable<String> {
        return AnonymousObservable { subscriber in
            
            let propagateChange = { (control: NSTextField) -> Void in
                let text: String = control.stringValue
                subscriber.on(.Next(Box(text)))
            }
            
            propagateChange(self)
            
            let observer = ControlTarget(control: self) { control in
                propagateChange(control as! NSTextField)
            }
            
            return observer
        }
    }
}