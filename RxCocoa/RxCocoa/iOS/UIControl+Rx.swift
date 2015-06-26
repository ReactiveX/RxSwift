//
//  UIControl+Rx.swift
//  RxCocoa
//
//  Created by Daniel Tartaglia on 5/23/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

extension UIControl {
    public func rx_controlEvents(controlEvents: UIControlEvents) -> Observable<Void> {
        return AnonymousObservable { observer in
            MainScheduler.ensureExecutingOnScheduler()
            
            let observer = ControlTarget(control: self, controlEvents: controlEvents) {
                control in
                sendNext(observer, ())
            }
            
            return observer
        }
    }
    
    func rx_value<T>(getValue: () -> T) -> Observable<T> {
        return AnonymousObservable { observer in
            
            sendNext(observer, getValue())
            
            let subscription = ControlTarget(control: self, controlEvents: UIControlEvents.EditingChanged) { control in
                sendNext(observer, getValue())
            }
            
            return subscription
            
        }
    }
}
