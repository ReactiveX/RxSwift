//
//  NSImageView+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 5/17/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import Cocoa

extension NSImageView {
    public func rx_subscribeImageTo(source: Observable<NSImage?>) -> Disposable {
        return rx_subscribeImageTo(false)(source: source)
    }
    
    public func rx_subscribeImageTo
        (animated: Bool)
        (source: Observable<NSImage?>) -> Disposable {
            MainScheduler.ensureExecutingOnScheduler()
            
            return source.subscribe(AnonymousObserver { event in
                switch event {
                case .Next(let boxedValue):
                    let value = boxedValue.value
                    if animated && value != nil {
                        let transition = CATransition()
                        transition.duration = 0.25
                        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                        transition.type = kCATransitionFade
                        self.layer!.addAnimation(transition, forKey: kCATransition)
                    }
                    else {
                        self.layer!.removeAllAnimations()
                    }
                    self.image = value
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
}
