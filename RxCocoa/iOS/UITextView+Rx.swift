//
//  UITextView+Rx.swift
//  RxCocoa
//
//  Created by Yuta ToKoRo on 7/19/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
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
    override func rx_createDelegateProxy() -> RxScrollViewDelegateProxy {
        return RxTextViewDelegateProxy(parentObject: self)
    }
    
    /**
    Reactive wrapper for `text` property.
    */
    public var rx_text: ControlProperty<String> {
        let source: Observable<String> = deferred { [weak self] in
            let text = self?.text ?? ""
            return (self?.rx_delegate.observe("textViewDidChange:") ?? empty())
                .map { a in
                    return (a[0] as? UITextView)?.text ?? ""
                }
                .startWith(text)
            }
        
        return ControlProperty(source: source, observer: AnyObserver { [weak self] event in
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
