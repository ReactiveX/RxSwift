//
//  NSControl+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 5/31/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import Cocoa
#if !RX_NO_MODULE
import RxSwift
#endif

extension NSControl {
    
    public var rx_controlEvents: Observable<Void> {
        return AnonymousObservable { observer in
            MainScheduler.ensureExecutingOnScheduler()
            
            let observer = ControlTarget(control: self) { control in
                sendNext(observer, ())
            }
            
            return observer
        }
    }
    
    func rx_value<T>(getValue: () -> T) -> Observable<T> {
        return AnonymousObservable { observer in
            sendNext(observer, getValue())
            
            let observer = ControlTarget(control: self) { control in
                sendNext(observer, getValue())
            }
            
            return observer
        }
    }
    
}