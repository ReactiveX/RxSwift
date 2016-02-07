//
//  NSView+Rx.swift
//  Rx
//
//  Created by Krunoslav Zaher on 12/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import Cocoa
#if !RX_NO_MODULE
import RxSwift
#endif

extension NSView {
    /**
     Bindable sink for `hidden` property.
     */
    public var rx_hidden: AnyObserver<Bool> {
        return self.rx_hiddenAnimated(nil)
    }
    
    /**
     Bindable sink for `hidden` property.
     
     - parameter transitionType: Optional transition type while setting the image (kCATransitionFade, kCATransitionMoveIn, ...)
     - parameter duration: Duration for the optional transition
     */
    public func rx_hiddenAnimated(transitionType: String?, duration: NSTimeInterval = 0.25) -> AnyObserver<Bool> {
        return AnyObserver { [weak self] event in
            MainScheduler.ensureExecutingOnScheduler()
            
            switch event {
            case .Next(let value):
                if let transitionType = transitionType {
                    let transition = CATransition()
                    transition.duration = duration
                    transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                    transition.type = transitionType
                    self?.layer?.addAnimation(transition, forKey: kCATransition)
                } else {
                    self?.layer?.removeAllAnimations()
                }
                self?.hidden = value
            case .Error(let error):
                bindingErrorToInterface(error)
                break
            case .Completed:
                break
            }
        }
    }
    
    /**
     Bindable sink for `alpha` property.
     */
    public var rx_alpha: AnyObserver<CGFloat> {
        return self.rx_alphaAnimated(nil)
    }
    
    /**
     Bindable sink for `alpha` property.
     
     - parameter transitionType: Optional transition type while setting the image (kCATransitionFade, kCATransitionMoveIn, ...)
     - parameter duration: Duration for the optional transition
     */
    public func rx_alphaAnimated(transitionType: String?, duration: NSTimeInterval = 0.25) -> AnyObserver<CGFloat> {
        return AnyObserver { [weak self] event in
            MainScheduler.ensureExecutingOnScheduler()
            
            switch event {
            case .Next(let value):
                if let transitionType = transitionType {
                    let transition = CATransition()
                    transition.duration = duration
                    transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                    transition.type = transitionType
                    self?.layer?.addAnimation(transition, forKey: kCATransition)
                } else {
                    self?.layer?.removeAllAnimations()
                }
                self?.alphaValue = value
            case .Error(let error):
                bindingErrorToInterface(error)
                break
            case .Completed:
                break
            }
        }
    }
}