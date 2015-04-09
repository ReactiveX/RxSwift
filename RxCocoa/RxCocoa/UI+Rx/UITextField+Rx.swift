//
//  UITextField+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

extension UITextField {
    public func rx_observableText() -> Observable<String> {
        return AnonymousObservable { subscriber in
            let observer = ControlTarget(control: self, controlEvents: UIControlEvents.EditingChanged) { control in
                let text: String = (control as! UITextField).text
                let result = subscriber.on(.Next(Box(text)))
                handleObserverResult(result)
            }
            
            return success(observer)
        }
    }
}