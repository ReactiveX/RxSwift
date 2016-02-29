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

extension UIBarButtonItem {
    
	/**
	Bindable sink for `enabled` property.
	*/
	public var rx_enabled: AnyObserver<Bool> {
        return UIBindingObserver(UIElement: self) { UIElement, value in
            UIElement.enabled = value
		}.asObserver()
	}
	
    /**
    Reactive wrapper for target action pattern on `self`.
    */
    public var rx_tap: ControlEvent<Void> {
        let source = rx_lazyInstanceObservable(&rx_tap_key) { () -> Observable<Void> in
            Observable.create { [weak self] observer in
                guard let control = self else {
                    observer.on(.Completed)
                    return NopDisposable.instance
                }
                let target = BarButtonItemTarget(barButtonItem: control) {
                    observer.on(.Next())
                }
                return target
            }
            .takeUntil(self.rx_deallocated)
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
    
    init(barButtonItem: UIBarButtonItem, callback: () -> Void) {
        self.barButtonItem = barButtonItem
        self.callback = callback
        super.init()
        barButtonItem.target = self
        barButtonItem.action = Selector("action:")
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
    
    func action(sender: AnyObject) {
        callback()
    }
    
}

#endif
