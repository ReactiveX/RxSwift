//
//  NSControl+Rx.swift
//  RxCocoa
//
//  Created by Junior B. on 24/05/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import Cocoa

extension NSSlider {
    public func rx_value() -> Observable<Double> {
        return AnonymousObservable { observer in
            MainScheduler.ensureExecutingOnScheduler()
            
            sendNext(observer, self.doubleValue)
            
            let observer = ControlTarget(control: self) { control in
                sendNext(observer, self.doubleValue)
            }
            
            return observer
        }
    }
}