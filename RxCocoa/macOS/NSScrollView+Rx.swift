//
//  NSScrollView+Rx.swift
//  Rx
//
//  Created by Christian Tietze on 26/05/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

#if os(macOS)

import Cocoa
#if !RX_NO_MODULE
import RxSwift
#endif

extension Reactive where Base: NSScrollView {

    /// Reactive wrapper for `backgroundColor` property.
    public var backgroundColor: ControlProperty<NSColor> {

        let source = self.observeWeakly(NSColor.self, "backgroundColor", options: [.initial, .new])
            .filter { $0 != nil }.map { $0! }
            .takeUntil(deallocated)

        let observer = UIBindingObserver(UIElement: base) { (scrollView, newColor: NSColor) in
            scrollView.backgroundColor = newColor
        }

        return ControlProperty(values: source, valueSink: observer)
    }
}

#endif
