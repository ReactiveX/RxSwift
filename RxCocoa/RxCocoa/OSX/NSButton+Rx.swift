//
//  NSButton+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 5/17/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import Cocoa

extension NSButton {
    public func rx_tap() -> Observable<Void> {
        return AnonymousObservable { subscriber in
            let observer = ControlTarget(control: self) { control in
                subscriber.on(.Next(Box(())))
            }
            
            return observer
        }
    }
}