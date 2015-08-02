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
    public func rx_subscribeImageTo(source: Observable<UIImage?>) -> Disposable {
        return rx_subscribeImageTo(false)(source)
    }
    
    public func rx_subscribeImageTo
        (animated: Bool)
        -> Observable<UIImage?> -> Disposable {
        return { source in
            return source.subscribe(AnonymousObserver { event in
                MainScheduler.ensureExecutingOnScheduler()
                
                switch event {
                case .Next(let boxedValue):
                    let value = boxedValue.value
                    if animated && value != nil {
                        let transition = CATransition()
                        transition.duration = 0.25
                        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                        transition.type = kCATransitionFade
                        self.layer.addAnimation(transition, forKey: kCATransition)
                    }
                    else {
                        self.layer.removeAllAnimations()
                    }
                    self.image = value
                case .Error(let error):
                    bindingErrorToInterface(error)
                    break
                case .Completed:
                    break
                }
            })
        }
    }
}