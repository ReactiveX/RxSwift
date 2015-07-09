//
//  UIDatePicker.swift
//  RxCocoa
//
//  Created by Daniel Tartaglia on 5/31/15.
//  Modified by Carlos García on 7/9/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

import Foundation
import RxSwift
import UIKit

extension UIDatePicker {
    
    public var rx_date: Observable<NSDate> {
        return AnonymousObservable { observer in
            
            sendNext(observer, self.date)
            
            let controlTarget = ControlTarget(control: self, controlEvents: UIControlEvents.ValueChanged) { control in
                sendNext(observer, (control as! UIDatePicker).date)
            }
            
            return AnonymousDisposable {
                controlTarget.dispose()
            }
        }
    }
    
}