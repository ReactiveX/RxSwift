//
//  UIBarButtonItem+Rx.swift
//  RxCocoa
//
//  Created by Daniel Tartaglia on 5/31/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif

var rx_tap_key: UInt8 = 0

extension Reactive where Base: UIBarButtonItem {
    
    /**
    Bindable sink for `enabled` property.
    */
    public var enabled: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { UIElement, value in
            UIElement.isEnabled = value
        }
    }

    /**
    Reactive wrapper for target action pattern on `self`.
    */
    public var tap: ControlEvent<Void> {
        let source = lazyInstanceObservable(&rx_tap_key) { () -> Observable<Void> in
            Observable.create { [weak control = self.base] observer in
                guard let control = control else {
                    observer.on(.completed)
                    return Disposables.create()
                }
                let target = BarButtonItemTarget(barButtonItem: control) {
                    observer.on(.next())
                }
                return target
            }
            .takeUntil(self.deallocated)
            .share()
        }
        
        return ControlEvent(events: source)
    }
}


@objc
class BarButtonItemTarget: RxTarget {
    typealias Callback = () -> Void
    
    weak var barButtonItem: UIBarButtonItem?
    var callback: Callback!
    
    init(barButtonItem: UIBarButtonItem, callback: @escaping () -> Void) {
        self.barButtonItem = barButtonItem
        self.callback = callback
        super.init()
        barButtonItem.target = self
        barButtonItem.action = #selector(BarButtonItemTarget.action(_:))
    }
    
    override func dispose() {
        super.dispose()
#if DEBUG
        MainScheduler.ensureExecutingOnScheduler()
#endif
        
        barButtonItem?.target = nil
        barButtonItem?.action = nil
        
        callback = nil
    }
    
    func action(_ sender: AnyObject) {
        callback()
    }
    
}

#endif
