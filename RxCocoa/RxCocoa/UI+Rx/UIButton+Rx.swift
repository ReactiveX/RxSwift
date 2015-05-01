//
//  UIButton+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

extension UIButton {
    public func rx_tap() -> Observable<Void> {
        return AnonymousObservable { subscriber in
            let observer = ControlTarget(control: self, controlEvents: UIControlEvents.TouchUpInside) { control in
                subscriber.on(.Next(Box(())))
            }
            
            return observer
        }
    }
}