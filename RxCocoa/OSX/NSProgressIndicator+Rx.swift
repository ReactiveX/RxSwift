//
//  NSProgressIndicator+Rx.swift
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


extension NSProgressIndicator {
    /**
     Reactive wrapper for starting and stopping the progress indicator animation.
     */
    public var rx_animating: AnyObserver<Bool> {
        return AnyObserver { [weak self] event in
            MainScheduler.ensureExecutingOnScheduler()
            
            switch event {
            case .Next(let value):
                if value {
                    self?.startAnimation(nil)
                } else {
                    self?.stopAnimation(nil)
                }
            case .Error(let error):
                bindingErrorToInterface(error)
            case .Completed:
                break
            }
        }
    }
}
