//
//  UIApplication+Rx.swift
//  RxExample
//
//  Created by Mads Bøgeskov on 18/01/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

#if os(iOS)
    import UIKit

#if !RX_NO_MODULE
    import RxSwift
#endif

    extension Reactive where Base: UIApplication {
        
        /**
         Bindable sink for `networkActivityIndicatorVisible`.
         */
        public var networkActivityIndicatorVisible: AnyObserver<Bool> {
            return UIBindingObserver(UIElement: self.base) { application, active in
                application.isNetworkActivityIndicatorVisible = active
            }.asObserver()
        }
    }
#endif

