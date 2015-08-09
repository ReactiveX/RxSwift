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

extension ObservableType where E == UIImage? {
    public func subscribeImageOf(imageView: UIImageView) -> Disposable {
        return subscribeImageOf(imageView, animated: false)
    }
    
    public func subscribeImageOf(imageView: UIImageView, animated: Bool) -> Disposable {
        return self.subscribe { event in
            MainScheduler.ensureExecutingOnScheduler()
            
            switch event {
            case .Next(let boxedValue):
                let value = boxedValue
                if animated && value != nil {
                    let transition = CATransition()
                    transition.duration = 0.25
                    transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                    transition.type = kCATransitionFade
                    imageView.layer.addAnimation(transition, forKey: kCATransition)
                }
                else {
                    imageView.layer.removeAllAnimations()
                }
                imageView.image = value
            case .Error(let error):
                bindingErrorToInterface(error)
                break
            case .Completed:
                break
            }
        }
    }
}

extension UIImageView {
}
