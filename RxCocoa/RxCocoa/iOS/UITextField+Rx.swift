//
//  UITextField+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

extension UITextField {
    public func rx_text() -> Observable<String> {
        return AnonymousObservable { observer in
            
            let propagateChange = { (control: UITextField) -> Void in
                let text: String = control.text
                
                sendNext(observer, text)
            }
            
            propagateChange(self)
            
            let subscription = ControlTarget(control: self, controlEvents: UIControlEvents.EditingChanged) { control in
                propagateChange(control as! UITextField)
            }
            
            return subscription
        }
    }
}