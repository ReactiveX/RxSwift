//
//  NSSegmentedControl+Rx.swift
//  RxCocoa
//
//  Created by Mykola Voronin on 10/3/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

#if os(macOS)
    
#if !RX_NO_MODULE
import RxSwift
#endif
import Cocoa
    
extension Reactive where Base: NSSegmentedControl {
    
    /// Reactive wrapper for `selectedSegment` property.
    public var selectedSegment: ControlProperty<Int> {
        return NSControl.rx.value(
            base,
            getter: { control in
                return control.selectedSegment
            },
            setter: { control, value in
                control.selectedSegment = value
            }
        )
    }
    
}
    
#endif
