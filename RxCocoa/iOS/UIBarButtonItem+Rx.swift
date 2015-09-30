//
//  UIBarButtonItem.swift
//  RxCocoa
//
//  Created by Daniel Tartaglia on 5/31/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif

extension UIBarButtonItem {
    
	/**
	Bindable sink for `enabled` property.
	*/
	public var rx_enabled: ObserverOf<Bool> {
		return ObserverOf { [weak self] event in
			MainScheduler.ensureExecutingOnScheduler()
			
			switch event {
			case .Next(let value):
				self?.enabled = value
			case .Error(let error):
				bindingErrorToInterface(error)
				break
			case .Completed:
				break
			}
		}
	}
	
    /**
    Reactive wrapper for target action pattern on `self`.
    */
    public var rx_tap: ControlEvent<Void> {
        let source: Observable<Void> = AnonymousObservable { observer in
            let target = BarButtonItemTarget(barButtonItem: self) {
                observer.on(.Next())
            }
            return target
        }.takeUntil(rx_deallocated)
        
        return ControlEvent(source: source)
    }
    
}


@objc
class BarButtonItemTarget: NSObject, Disposable {
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
    
    deinit {
        dispose()
    }
    
    func dispose() {
        MainScheduler.ensureExecutingOnScheduler()
        
        barButtonItem?.target = nil
        barButtonItem?.action = nil
        
        callback = nil
    }
    
    func action(sender: AnyObject) {
        callback()
    }
    
}

#endif
