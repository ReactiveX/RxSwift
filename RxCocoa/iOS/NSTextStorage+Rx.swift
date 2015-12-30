//
//  NSTextStorage+Rx.swift
//  Rx
//
//  Created by Segii Shulga on 12/30/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)
    
    import Foundation
    import UIKit
#if !RX_NO_MODULE
    import RxSwift
#endif

extension NSTextStorage {
    
    public var rx_delegate:DelegateProxy {
        return proxyForObject(RxTextStorageDelegateProxy.self, self)
    }
    
    public var rx_string:Observable<String> {
        return rx_delegate
            .observe("textStorage:didProcessEditing:range:changeInLength:")
            .map({ a  in
                let textStorage:NSTextStorage = castOrFatalError(a[0])
                return textStorage.string
            })
            .distinctUntilChanged() // dont know why, but system call delegate twice on auto correction
    }
}

#endif