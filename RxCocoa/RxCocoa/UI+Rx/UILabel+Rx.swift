//
//  UILabel+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 4/1/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

extension UILabel {
    public func rx_subscribeTextTo(source: Observable<String>) -> Result<Disposable> {
        return source.subscribe(ObserverOf(AnonymousObserver { event in
            switch event {
            case .Next(let boxedValue):
                let value = boxedValue.value
                self.text = value
            case .Error(let error):
                rxFatalError("Binding error to textbox: \(error)")
                break
            case .Completed:
                break
            }
            
            return SuccessResult
        }))
    }
}