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
    public typealias WillRepositionPopoverEvent =
        (toRect: UnsafeMutablePointer<CGRect>, inView: AutoreleasingUnsafeMutablePointer<UIView>)
    
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
    
    public var willReposition: ControlEvent<WillRepositionPopoverEvent> {
        let source = delegate
            .methodInvoked(#selector(UIPopoverPresentationControllerDelegate.popoverPresentationController(_:willRepositionPopoverTo:in:)))
            .map { args -> WillRepositionPopoverEvent in
                let rect = try castOrThrow(NSValue.self, args[1])
                let view = try castOrThrow(NSValue.self, args[2])
                
                guard let rawRectPointer = rect.pointerValue else { throw RxCocoaError.unknown }
                let typedRectPointer = rawRectPointer.bindMemory(to: CGRect.self, capacity: MemoryLayout<CGRect>.size)
                
                guard let rawViewPointer = view.pointerValue else { throw RxCocoaError.unknown }
                let typedViewPointer = rawViewPointer.bindMemory(to: UIView.self, capacity: MemoryLayout<UIView>.size)
                
                return (typedRectPointer, .init(typedViewPointer))
            }
        
        return ControlEvent(events: source)
    }
    
    public func setDelegate(_ delegate: UIPopoverPresentationControllerDelegate) -> Disposable {
        return RxPopoverPresentationControllerProxy
            .installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: self.base)
    }
}

#endif
