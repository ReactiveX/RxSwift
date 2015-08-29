//
//  UITextView+Rx.swift
//  RxCocoa
//
//  Created by Yuta ToKoRo on 7/19/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif

extension UITextView {
    
    override func rx_createDelegateProxy() -> RxScrollViewDelegateProxy {
        return RxTextViewDelegateProxy(parentObject: self)
    }
    
    public var rx_text: ControlProperty<String> {
        let source: Observable<String> = deferred { [weak self] in
            let text = self?.text ?? ""
            return (self?.rx_delegate.observe("textViewDidChange:") ?? empty())
                .map { a in
                    return (a[0] as? UITextView)?.text ?? ""
                }
                .startWith(text)
            }
        
        return ControlProperty(source: source, observer: ObserverOf { [weak self] event in
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
