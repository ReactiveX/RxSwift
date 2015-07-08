//
//  UISwitch+Rx.swift
//  RxCocoa
//
//  Created by Carlos García on 8/7/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit
import RxSwift


extension UISwitch {
    
    public var rx_value: Observable<Bool> {
        return AnonymousObservable { observer in
            
            sendNext(observer, self.on)
            
            let controlTarget = ControlTarget(control: self, controlEvents: UIControlEvents.ValueChanged) { control in
                sendNext(observer, (control as! UISwitch).on)
            }
            
            return AnonymousDisposable {
                controlTarget.dispose()
            }
        }
    }
    
}