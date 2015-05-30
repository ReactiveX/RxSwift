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
    
    public func rx_controlEvents(controlEvents: UIControlEvents) -> Observable<UIControl> {
        return AnonymousObservable { observer in
            MainScheduler.ensureExecutingOnScheduler()
            
            let observer = ControlTarget(control: self, controlEvents: controlEvents) {
                control in
                sendNext(observer, control)
            }
            
            return observer
        }
    }

}
