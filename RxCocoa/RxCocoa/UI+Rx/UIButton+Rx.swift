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
    public func rx_observableTap() -> Observable<Void> {
        return AnonymousObservable { subscriber in
            let observer = ControlTarget(control: self, controlEvents: UIControlEvents.TouchUpInside) { control in
                let result = subscriber.on(.Next(Box(())))
                handleObserverResult(result)
            }
            
            return success(observer)
        }
    }
}