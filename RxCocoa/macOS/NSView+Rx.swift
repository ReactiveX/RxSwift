//
//  NSView+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 12/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(macOS)
import Cocoa
import RxSwift

public extension Reactive where Base: NSView {
    /// Bindable sink for `alphaValue` property.
    var alpha: Binder<CGFloat> {
        Binder(base) { view, value in
            view.alphaValue = value
        }
    }
}
#endif
