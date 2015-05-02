//
//  ControlTarget.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

// This should be only used from `MainScheduler`
class ControlTarget: NSObject, Disposable {
    typealias Callback = (UIControl) -> Void
    
    let selector: Selector = "eventHandler:"
    
    let control: UIControl
    let controlEvents: UIControlEvents
    var callback: Callback?
    
    init(control: UIControl, controlEvents: UIControlEvents, callback: Callback) {
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
   
    func eventHandler(sender: UIControl!) {
        if let callback = self.callback {
            callback(self.control)
        }
    }
    
    func dispose() {
        MainScheduler.ensureExecutingOnScheduler()
        
        self.control.removeTarget(self, action: self.selector, forControlEvents: self.controlEvents)
        self.callback = nil
    }
    
    deinit {
        self.control.removeTarget(self, action: selector, forControlEvents: controlEvents)
    }
}