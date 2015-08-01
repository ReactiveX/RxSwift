//
//  UIGestureRecognizer+Rx.swift
//  Touches
//
//  Created by Carlos García on 10/6/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif


// This should be only used from `MainScheduler`
class GestureTarget: RxTarget {
    typealias Callback = (UIGestureRecognizer) -> Void
    
    let selector = Selector("eventHandler:")
    
    unowned let gestureRecognizer: UIGestureRecognizer
    var callback: Callback?
    
    init(_ gestureRecognizer: UIGestureRecognizer, callback: Callback) {
        self.gestureRecognizer = gestureRecognizer
        self.callback = callback
        
        super.init()
        
        gestureRecognizer.addTarget(self, action: selector)
        
        let method = self.methodForSelector(selector)
        if method == nil {
            fatalError("Can't find method")
        }
    }
    
    func eventHandler(sender: UIGestureRecognizer!) {
        if let callback = self.callback {
            callback(self.gestureRecognizer)
        }
    }
    
    override func dispose() {
        super.dispose()
        
        self.gestureRecognizer.removeTarget(self, action: self.selector)
        self.callback = nil
    }
}

extension UIGestureRecognizer {
    
    public var rx_event: Observable<UIGestureRecognizer> {
        return AnonymousObservable { observer in
            MainScheduler.ensureExecutingOnScheduler()
            
            let observer = GestureTarget(self) {
                control in
                sendNext(observer, self)
            }
            
            return observer
        } >- takeUntil(rx_deallocated)
    }
    
}