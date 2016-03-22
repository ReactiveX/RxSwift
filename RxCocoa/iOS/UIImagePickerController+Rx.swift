//
//  UIImagePickerController+Rx.swift
//  Rx
//
//  Created by Segii Shulga on 1/4/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

#if os(iOS)
    import Foundation

#if !RX_NO_MODULE
    import RxSwift
#endif
    import UIKit

    extension UIImagePickerController {

        /**
         Reactive wrapper for `delegate`.

         For more information take a look at `DelegateProxyType` protocol documentation.
         */
        public var rx_delegate: DelegateProxy {
            return proxyForObject(RxImagePickerDelegateProxy.self, self)
        }

        /**
         Reactive wrapper for `delegate` message.
         */
        public var rx_didFinishPickingMediaWithInfo: Observable<[String : AnyObject]> {
            return rx_delegate
                .observe(#selector(UIImagePickerControllerDelegate.imagePickerController(_:didFinishPickingMediaWithInfo:)))
                .map({ (a) in
                    return try castOrThrow(Dictionary<String, AnyObject>.self, a[1])
                })
        }

        /**
         Reactive wrapper for `delegate` message.
         */
        public var rx_didCancel: Observable<()> {
            return rx_delegate
                .observe(#selector(UIImagePickerControllerDelegate.imagePickerControllerDidCancel(_:)))
                .map {_ in () }
        }
        
    }
    
#endif
