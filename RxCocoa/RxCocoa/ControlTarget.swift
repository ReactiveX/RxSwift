//
//  ControlTarget.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

#if os(iOS)
    import UIKit
    
    typealias Control = UIKit.UIControl
    typealias ControlEvents = UIKit.UIControlEvents
#elseif os(OSX)
    import Cocoa
    
    typealias Control = Cocoa.NSControl
#endif

// This should be only used from `MainScheduler`
class ControlTarget: NSObject, Disposable {
    typealias Callback = (Control) -> Void
    
    let selector: Selector = "eventHandler:"
    
    let control: Control
#if os(iOS)
    let controlEvents: UIControlEvents
#endif
    var callback: Callback?
    
#if os(iOS)
    init(control: Control, controlEvents: UIControlEvents, callback: Callback) {
        self.control = control
        self.controlEvents = controlEvents
        self.callback = callback
        
        super.init()
        
        control.addTarget(self, action: selector, forControlEvents: controlEvents)
        
        let method = self.methodForSelector(selector)
        if method == nil {
            rxFatalError("Can't find method")
        }
    }
#elseif os(OSX)
    init(control: Control, callback: Callback) {
        self.control = control
        self.callback = callback
        
        super.init()
        
        control.target = self
        control.action = selector
        
        let method = self.methodForSelector(selector)
        if method == nil {
            rxFatalError("Can't find method")
        }
    }
#endif
   
    func eventHandler(sender: Control!) {
        if let callback = self.callback {
            callback(self.control)
        }
    }
    
    func dispose() {
        MainScheduler.ensureExecutingOnScheduler()
        
#if os(iOS)
        self.control.removeTarget(self, action: self.selector, forControlEvents: self.controlEvents)
#elseif os(OSX)
        self.control.target = nil
        self.control.action = nil
#endif
        self.callback = nil
    }
    
    deinit {
        dispose()
    }
}