//
//  UIPopoverPresentationController+Rx.swift
//  RxSwift-iOS
//
//  Created by Vladimir Kushelkov on 31/03/2018.
//  Copyright © 2018 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)

import UIKit
import RxSwift

@available(iOS 8.0, *)
extension Reactive where Base: UIPopoverPresentationController {
    public var delegate: DelegateProxy<UIPopoverPresentationController, UIPopoverPresentationControllerDelegate> {
        return RxPopoverPresentationControllerProxy.proxy(for: base)
    }
    
    public var didDismiss: Observable<Void> {
        return delegate
            .methodInvoked(#selector(UIPopoverPresentationControllerDelegate.popoverPresentationControllerDidDismissPopover(_:)))
            .map {_ in}
    }
    
    public var prepareForPresentation: Observable<Void> {
        return delegate
            .methodInvoked(#selector(UIPopoverPresentationControllerDelegate.prepareForPopoverPresentation(_:)))
            .map {_ in}
    }
    
    public func setDelegate(_ delegate: UIPopoverPresentationControllerDelegate) -> Disposable {
        return RxPopoverPresentationControllerProxy
            .installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: self.base)
    }
}

#endif
