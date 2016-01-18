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

extension UIBarButtonItem {
    
	/**
	Bindable sink for `enabled` property.
	*/
	public var rx_enabled: AnyObserver<Bool> {
		return AnyObserver { [weak self] event in
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
        if let target = self.target as? BarButtonItemTarget {
            return target.event
        }
        return BarButtonItemTarget(barButtonItem: self).event
    }
}


@objc
class BarButtonItemTarget: RxTarget {
    typealias Callback = () -> Void
    
    weak var barButtonItem: UIBarButtonItem?
    var callback: Callback!
    
    var event: ControlEvent<Void>!
    
    init(barButtonItem: UIBarButtonItem) {
        self.barButtonItem = barButtonItem
        super.init()
        barButtonItem.target = self
        barButtonItem.action = Selector("action:")
        
        self.event = ControlEvent(events:
            Observable.create { [weak self] observer in
                guard let target = self else {
                    observer.on(.Completed)
                    return NopDisposable.instance
                }
                target.callback = {
                    observer.on(.Next())
                }
                return target
            }.takeUntil(barButtonItem.rx_deallocated).share()
        )
    }

    override func dispose() {
        super.dispose()
#if DEBUG
        MainScheduler.ensureExecutingOnScheduler()
#endif

        barButtonItem?.target = nil
        barButtonItem?.action = nil
        
        callback = nil
        event = nil
    }
    
    func action(sender: AnyObject) {
        callback()
    }
}

#endif
