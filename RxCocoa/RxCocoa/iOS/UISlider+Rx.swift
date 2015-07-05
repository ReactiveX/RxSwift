//
//  UISlider+Rx.swift
//  RxCocoa
//
//  Created by Alexander van der Werff on 28/05/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

extension UISlider {
    public var rx_value: Observable<Float> {
        return AnonymousObservable { observer in
            MainScheduler.ensureExecutingOnScheduler()
            
            sendNext(observer, self.value)
            
            let observer = ControlTarget(control: self, controlEvents: UIControlEvents.ValueChanged) { control in
                sendNext(observer, (control as! UISlider).value)
            }
            
            return AnonymousDisposable {
                observer.dispose()
            }
        }
    }
}