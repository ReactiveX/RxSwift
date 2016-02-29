//
//  NSImageView+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 5/17/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import Cocoa

extension NSImageView {
   
    /**
    Bindable sink for `image` property.
    */
    public var rx_image: AnyObserver<NSImage?> {
        return self.rx_imageAnimated(nil)
    }
    
    /**
    Bindable sink for `image` property.
    
    - parameter transitionType: Optional transition type while setting the image (kCATransitionFade, kCATransitionMoveIn, ...)
    */
    public func rx_imageAnimated(transitionType: String?) -> AnyObserver<NSImage?> {
        return UIBindingObserver(UIElement: self) { control, value in
            if let transitionType = transitionType {
                if value != nil {
                    let transition = CATransition()
                    transition.duration = 0.25
                    transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                    transition.type = transitionType
                    control.layer?.addAnimation(transition, forKey: kCATransition)
                }
            }
            else {
                control.layer?.removeAllAnimations()
            }
            control.image = value
        }.asObserver()
    }
    
}
