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
        let source: Observable<String> = Observable.deferred { [weak self] in
            let text = self?.text ?? ""
            
            let textChanged = self?.textStorage
                .rx_didProcessEditingRangeChangeInLength
                .map { _ in
                    return self?.textStorage.string ?? ""
                }
                ?? Observable.empty()
            
            return textChanged
                .startWith(text)
                .distinctUntilChanged()
        }

        let bindingObserver = UIBindingObserver(UIElement: self) { (textView, text: String) in
            textView.text = text
        }
        
        return ControlProperty(values: source, valueSink: bindingObserver)
    }
    
}

#endif
