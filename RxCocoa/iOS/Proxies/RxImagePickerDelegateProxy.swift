//
//  RxImagePickerDelegateProxy.swift
//  Rx
//
//  Created by Segii Shulga on 1/4/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)
   
   import Foundation
#if !RX_NO_MODULE
   import RxSwift
#endif
   import UIKit

public class RxImagePickerDelegateProxy
    : DelegateProxy
    , DelegateProxyType
    , UIImagePickerControllerDelegate
    , UINavigationControllerDelegate {
    
    /**
     For more information take a look at `DelegateProxyType`.
     */
    public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let imagePickerController: UIImagePickerController = castOrFatalError(object)
        imagePickerController.delegate = castOptionalOrFatalError(delegate)
    }
    
    /**
     For more information take a look at `DelegateProxyType`.
     */
    public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let imagePickerController: UIImagePickerController = castOrFatalError(object)
        return imagePickerController.delegate
    }

}
   
#endif
