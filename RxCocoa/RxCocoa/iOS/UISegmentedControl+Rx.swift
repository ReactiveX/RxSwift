//
//  UISegmentedControl+Rx.swift
//  RxCocoa
//
//  Created by Carlos García on 8/7/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit
import RxSwift


extension UISegmentedControl {
    
    public var rx_value: Observable<Int> {
        return AnonymousObservable { observer in
            
            sendNext(observer, self.selectedSegmentIndex)
            
            let controlTarget = ControlTarget(control: self, controlEvents: UIControlEvents.ValueChanged) { control in
                sendNext(observer, (control as! UISegmentedControl).selectedSegmentIndex)
            }
            
            return AnonymousDisposable {
                controlTarget.dispose()
            }
        }
    }
    
}