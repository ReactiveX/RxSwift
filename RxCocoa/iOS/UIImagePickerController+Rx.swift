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
    
    public var rx_delegate: DelegateProxy {
        return proxyForObject(RxImagePickerDelegateProxy.self, self)
    }
    
    public var rx_didFinishPickingMediaWithInfo: Observable<[String : AnyObject]> {
        return rx_delegate
            .observe("imagePickerController:didFinishPickingMediaWithInfo:")
            .map({ (a) in
                return try castOrThrow(Dictionary<String, AnyObject>.self, a[1])
            })
    }
   
   public var rx_didCancel: Observable<Void> {
      return rx_delegate
         .observe("imagePickerControllerDidCancel:")
         .map({_ in ()})
   }
    
}
    
#endif
