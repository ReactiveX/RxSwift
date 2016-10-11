//
//  UIImageView+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 4/1/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import UIKit

extension Reactive where Base: UIImageView {
    
    /**
    Bindable sink for `image` property.
    */
    public var image: UIBindingObserver<Base, UIImage?> {
        return image(transitionType: nil)
    }
    
    /**
    Bindable sink for `image` property.
    
    - parameter transitionType: Optional transition type while setting the image (kCATransitionFade, kCATransitionMoveIn, ...)
    */
    @available(*, deprecated, renamed: "image(transitionType:)")
    public func imageAnimated(_ transitionType: String?) -> UIBindingObserver<Base, UIImage?> {
        return UIBindingObserver(UIElement: base) { imageView, image in
            if let transitionType = transitionType {
                if image != nil {
                    let transition = CATransition()
                    transition.duration = 0.25
                    transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                    transition.type = transitionType
                    imageView.layer.add(transition, forKey: kCATransition)
                }
            }
            else {
                imageView.layer.removeAllAnimations()
            }
            imageView.image = image
        }
    }

    /**
     Bindable sink for `image` property.

     - parameter transitionType: Optional transition type while setting the image (kCATransitionFade, kCATransitionMoveIn, ...)
     */
    public func image(transitionType: String? = nil) -> UIBindingObserver<Base, UIImage?> {
        return UIBindingObserver(UIElement: base) { imageView, image in
            if let transitionType = transitionType {
                if image != nil {
                    let transition = CATransition()
                    transition.duration = 0.25
                    transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                    transition.type = transitionType
                    imageView.layer.add(transition, forKey: kCATransition)
                }
            }
            else {
                imageView.layer.removeAllAnimations()
            }
            imageView.image = image
        }
    }
}

#endif
