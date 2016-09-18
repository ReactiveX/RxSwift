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
    import RxCocoa
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
    public class func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
        let imagePickerController: UIImagePickerController = castOrFatalError(object)
        imagePickerController.delegate = castOptionalOrFatalError(delegate)
    }
    
    /**
     For more information take a look at `DelegateProxyType`.
     */
    public class func currentDelegateFor(object: AnyObject) -> AnyObject? {
        let imagePickerController: UIImagePickerController = castOrFatalError(object)
        return imagePickerController.delegate
    }

}

    private func castOrFatalError<T>(value: Any!) -> T {
        let maybeResult: T? = value as? T
        guard let result = maybeResult else {
            rxFatalError("Failure converting from \(value) to \(T.self)")
        }

        return result
    }

    private func castOptionalOrFatalError<T>(value: AnyObject?) -> T? {
        if value == nil {
            return nil
        }
        let v: T = castOrFatalError(value)
        return v
    }

    @noreturn private func rxFatalError(lastMessage: String) {
        // The temptation to comment this line is great, but please don't, it's for your own good. The choice is yours.
        fatalError(lastMessage)
    }
    
#endif
