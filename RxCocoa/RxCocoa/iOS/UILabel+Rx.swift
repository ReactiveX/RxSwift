//
//  UILabel+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 4/1/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import UIKit

extension UILabel {
    public func rx_subscribeTextTo(source: Observable<String>) -> Disposable {
        return source.subscribe(AnonymousObserver { event in
            MainScheduler.ensureExecutingOnScheduler()
            
            switch event {
            case .Next(let boxedValue):
                let value = boxedValue.value
                self.text = value
            case .Error(let error):
#if DEBUG
                rxFatalError("Binding error to textbox: \(error)")
#endif
                break
            case .Completed:
                break
            }
        })
    }
}