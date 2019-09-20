//
//  NSBox+Rx.swift
//  RxCocoa
//
//  Created by bugkingK on 20/09/2019.
//  Copyright © 2019 Krunoslav Zaher. All rights reserved.
//

#if os(macOS)
import Cocoa
import RxSwift

extension Reactive where Base: NSBox {
    /// Bindable sink for `hidden` property.
    public var isHidden:  Binder<Bool> {
        return Binder(self.base) { view, value in
            view.isHidden = value
        }
    }

    /// Bindable sink for `alphaValue` property.
    public var alpha: Binder<CGFloat> {
        return Binder(self.base) { view, value in
            view.alphaValue = value
        }
    }
    
    /// Bindable sink for `fillColor` property.
    public var fillColor: Binder<NSColor> {
        return Binder(self.base) { view, value in
            view.fillColor = value
        }
    }
}

#endif

