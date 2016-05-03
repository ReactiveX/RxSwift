//
//  UIGestureRecognizer+Rx.swift
//  Touches
//
//  Created by Carlos García on 10/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif


// This should be only used from `MainScheduler`
class GestureTarget<Recognizer: UIGestureRecognizer>: RxTarget {
    typealias Callback = (Recognizer) -> Void
    
    let selector = #selector(ControlTarget.eventHandler(_:))
    
    weak var gestureRecognizer: Recognizer?
    var callback: Callback?
    
    init(_ gestureRecognizer: Recognizer, callback: Callback) {
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
        if let callback = self.callback, gestureRecognizer = self.gestureRecognizer {
            callback(gestureRecognizer)
        }
    }
    
    override func dispose() {
        super.dispose()
        
        self.gestureRecognizer?.removeTarget(self, action: self.selector)
        self.callback = nil
    }
}

extension UIGestureRecognizer: Reactive  { }

extension Reactive where Self: UIGestureRecognizer {
    
    /**
    Reactive wrapper for gesture recognizer events.
    */
    public var rx_event: ControlEvent<Self> {
        let source: Observable<Self> = Observable.create { [weak self] observer in
            MainScheduler.ensureExecutingOnScheduler()

            guard let control = self else {
                observer.on(.Completed)
                return NopDisposable.instance
            }
            
            let observer = GestureTarget(control) {
                control in
                observer.on(.Next(control))
            }
            
            return observer
        }.takeUntil(rx_deallocated)
        
        return ControlEvent(events: source)
    }
    
}

#endif
