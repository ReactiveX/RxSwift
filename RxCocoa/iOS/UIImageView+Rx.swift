//
//  UIImageView+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 4/1/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import UIKit

extension UIImageView {
    
    /**
    Bindable sink for `image` property.
    */
    public var rx_image: ObserverOf<UIImage!> {
        return self.rx_imageAnimated(nil)
    }
    
    /**
    Bindable sink for `image` property.
    
    - parameter transitionType: Optional transition type while setting the image (kCATransitionFade, kCATransitionMoveIn, ...)
    */
    public func rx_imageAnimated(transitionType: String?) -> ObserverOf<UIImage!> {
        return ObserverOf { [weak self] event in
            MainScheduler.ensureExecutingOnScheduler()
            
            switch event {
            case .Next(let value):
                if let transitionType = transitionType {
                    if value != nil {
                        let transition = CATransition()
                        transition.duration = 0.25
                        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                        transition.type = transitionType
                        self?.layer.addAnimation(transition, forKey: kCATransition)
                    }
                }
                else {
                    self?.layer.removeAllAnimations()
                }
                self?.image = value
            case .Error(let error):
                bindingErrorToInterface(error)
                break
            case .Completed:
                break
            }
        }
    }
    
}
