//
//  RxGestureRecognizerDelegateProxy.swift
//  Rx
//
//  Created by Maksym Shcheglov on 08/06/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

    import Foundation
#if !RX_NO_MODULE
    import RxSwift
#endif
    import UIKit

/**
 For more information take a look at `DelegateProxyType`.
 */
public class RxGestureRecognizerDelegateProxy
    : DelegateProxy
    , DelegateProxyType
    , UIGestureRecognizerDelegate {

    /**
     For more information take a look at `DelegateProxyType`.
     */
    public class func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
        let gestureRecognizer: UIGestureRecognizer = castOrFatalError(object)
        gestureRecognizer.delegate = castOptionalOrFatalError(delegate)
    }

    /**
     For more information take a look at `DelegateProxyType`.
     */
    public class func currentDelegateFor(object: AnyObject) -> AnyObject? {
        let gestureRecognizer: UIGestureRecognizer = castOrFatalError(object)
        return gestureRecognizer.delegate
    }

    /**
     For more information take a look at `DelegateProxyType`.
     */
    public override class func createProxyForObject(object: AnyObject) -> AnyObject {
        let gestureRecognizer = (object as! UIGestureRecognizer)

        return castOrFatalError(gestureRecognizer.rx_createDelegateProxy())
    }
}

#endif
