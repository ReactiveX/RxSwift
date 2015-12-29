//
//  UITextView+Rx.swift
//  RxCocoa
//
//  Created by Yuta ToKoRo on 7/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import Foundation
import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif

extension UITextView {
    
    /**
    Factory method that enables subclasses to implement their own `rx_delegate`.
    
    - returns: Instance of delegate proxy that wraps `delegate`.
    */
    public override func rx_createDelegateProxy() -> RxScrollViewDelegateProxy {
        return RxTextViewDelegateProxy(parentObject: self)
    }
    
    /**
    Reactive wrapper for `text` property.
    */
    public var rx_text: ControlProperty<String> {
        let source: Observable<String> = Observable.deferred { [weak self] () -> Observable<String> in
            let text = self?.text ?? ""
            // basic event
            let textChangedEvent = self?.rx_delegate.observe("textViewDidChange:") ?? Observable.empty()

            // Monitor all other events because text could change without user intervention and without
            // `textViewDidChange:` firing.
            // For example, autocorrecting spell checker.
            let anyOtherEvent = (self?.rx_delegate as? RxTextViewDelegateProxy)?.textChanging ?? Observable.empty()

            // Throttle is here because textChanging will fire when text is about to change.
            // Event needs to happen after text is changed. This is kind of a hacky way, but
            // don't know any other way for now.
            let throttledAnyOtherEvent = anyOtherEvent
                .throttle(0, scheduler: MainScheduler.instance)
                .takeUntil(self?.rx_deallocated ?? Observable.just())

            return Observable.of(textChangedEvent.map { _ in () }, throttledAnyOtherEvent)
                .merge()
                .map { a in
                    return self?.text ?? ""
                }
                .startWith(text)
                .distinctUntilChanged()
            }
        
        return ControlProperty(values: source, valueSink: AnyObserver { [weak self] event in
            switch event {
            case .Next(let value):
                self?.text = value
            case .Error(let error):
                bindingErrorToInterface(error)
            case .Completed:
                break
            }
        })
    }
    
}

#endif
