//
//  UIApplication+Rx.swift
//  RxExample
//
//  Created by Mads Bøgeskov on 18/01/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

#if os(iOS) || os(tvOS)
    import UIKit
    
#if !RX_NO_MODULE
    import RxSwift
#endif
    
    extension UIApplication {
        
        /**
         Bindable sink for `networkActivityIndicatorVisible`.
         */
        public var rx_networkActivityIndicatorVisible: AnyObserver<Bool> {
            return AnyObserver { event in
                MainScheduler.ensureExecutingOnScheduler()
                switch event {
                case .Next(let value):
                    self.networkActivityIndicatorVisible = value
                case .Error(let error):
                    bindingErrorToInterface(error)
                case .Completed:
                    break
                }
            }
        }
    }
#endif