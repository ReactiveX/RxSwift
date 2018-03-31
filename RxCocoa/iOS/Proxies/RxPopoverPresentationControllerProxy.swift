//
//  RxPopoverPresentationControllerProxy.swift
//  RxSwift-iOS
//
//  Created by Vladimir Kushelkov on 31/03/2018.
//  Copyright © 2018 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)

import UIKit
import RxSwift

@available(iOS 8.0, *)
extension UIPopoverPresentationController: HasDelegate {
    public typealias Delegate = UIPopoverPresentationControllerDelegate
}

@available(iOS 8.0, *)
open class RxPopoverPresentationControllerProxy
    : DelegateProxy<UIPopoverPresentationController, UIPopoverPresentationControllerDelegate>
    , UIPopoverPresentationControllerDelegate
    , DelegateProxyType {
    
    public weak private(set) var popoverPresentationController: UIPopoverPresentationController?
    
    public init(popoverPresentationController: UIPopoverPresentationController) {
        self.popoverPresentationController = popoverPresentationController
        super.init(parentObject: popoverPresentationController,
                   delegateProxy: RxPopoverPresentationControllerProxy.self)
    }
    
    public static func registerKnownImplementations() {
        self.register { RxPopoverPresentationControllerProxy(popoverPresentationController: $0) }
    }
}

#endif
