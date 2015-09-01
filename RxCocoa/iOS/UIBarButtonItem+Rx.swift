//
//  UIBarButtonItem.swift
//  RxCocoa
//
//  Created by Daniel Tartaglia on 5/31/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif

extension UIBarButtonItem {
    
    public var rx_tap: ControlEvent<Void> {
        let source: Observable<Void> = AnonymousObservable { observer in
            let target = BarButtonItemTarget(barButtonItem: self) {
                observer.on(.Next())
            }
            return target
        }.takeUntil(rx_deallocated)
        
        return ControlEvent(source: source)
    }
    
}


@objc
class BarButtonItemTarget: NSObject, Disposable {
    typealias Callback = () -> Void
    
    weak var barButtonItem: UIBarButtonItem?
    var callback: Callback!
    
    init(barButtonItem: UIBarButtonItem, callback: () -> Void) {
        self.barButtonItem = barButtonItem
        self.callback = callback
        super.init()
        barButtonItem.target = self
        barButtonItem.action = Selector("action:")
    }
    
    deinit {
        dispose()
    }
    
    func dispose() {
        MainScheduler.ensureExecutingOnScheduler()
        
        barButtonItem?.target = nil
        barButtonItem?.action = nil
        
        callback = nil
    }
    
    func action(sender: AnyObject) {
        callback()
    }
    
}