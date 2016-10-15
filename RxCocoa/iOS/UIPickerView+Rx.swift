//
//  UIPickerView+Rx.swift
//  RxCocoa
//
//  Created by Segii Shulga on 5/12/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)
    
    import Foundation
#if !RX_NO_MODULE
    import RxSwift
#endif
    import UIKit

extension Reactive where Base: UIPickerView {
    /**
     Reactive wrapper for `delegate`.
     For more information take a look at `DelegateProxyType` protocol documentation.
     */
    public var delegate: DelegateProxy {
        return RxPickerViewDelegateProxy.proxyForObject(base)
    }
    
    public var itemSelected: ControlEvent<(Int, Int)> {
        let source = delegate
            .methodInvoked(#selector(UIPickerViewDelegate.pickerView(_:didSelectRow:inComponent:)))
            .map {
                return (try castOrThrow(Int.self, $0[1]), try castOrThrow(Int.self, $0[2]))
            }
        return ControlEvent(events: source)
    }
}

#endif
