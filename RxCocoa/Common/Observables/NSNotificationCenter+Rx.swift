//
//  NSNotificationCenter+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 5/2/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif

extension NSNotificationCenter {
    public func rx_notification(name: String, object: AnyObject?) -> Observable<NSNotification> {
        return AnonymousObservable { observer in
            let nsObserver = self.addObserverForName(name, object: object, queue: nil) { notification in
                observer.on(.Next(notification))
            }
            
            return AnonymousDisposable {
                self.removeObserver(nsObserver)
            }
        }
    }
}