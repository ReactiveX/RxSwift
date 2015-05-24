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
    public func rx_valueChange() -> Observable<Double> {
        return AnonymousObservable { observer in
            MainScheduler.ensureExecutingOnScheduler()
            
            let observer = ControlTarget(control: self) { control in
                sendNext(observer, self.doubleValue)
            }
            
            return observer
        }
    }
}