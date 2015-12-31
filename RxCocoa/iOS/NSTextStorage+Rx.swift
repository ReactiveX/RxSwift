//
//  NSTextStorage+Rx.swift
//  Rx
//
//  Created by Segii Shulga on 12/30/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

#if !RX_NO_MODULE
    import RxSwift
#endif
    import UIKit

extension NSTextStorage {
    
    public var rx_delegate:DelegateProxy {
        return proxyForObject(RxTextStorageDelegateProxy.self, self)
    }
    
    public var rx_didProcessEditingRangeChangeInLength: Observable<(editedMask:NSTextStorageEditActions, editedRange:NSRange, delta:Int)> {
        return rx_delegate
            .observe("textStorage:didProcessEditing:range:changeInLength:")
            .map({ (a) in
                let editedMask:NSTextStorageEditActions = NSTextStorageEditActions(rawValue: castOrFatalError(a[1]) as UInt)
                let editedRange:NSRange = (castOrFatalError(a[2]) as NSValue).rangeValue
                let delta:Int = castOrFatalError(a[3])
                
                return (editedMask, editedRange, delta)
            })
    }
}
