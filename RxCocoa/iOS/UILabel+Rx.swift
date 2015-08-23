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

extension ObservableType where E == String {
    public func subscribeTextOf(label: UILabel) -> Disposable {
        return self.subscribe { event in
            MainScheduler.ensureExecutingOnScheduler()
            
            switch event {
            case .Next(let value):
                label.text = value
            case .Error(let error):
#if DEBUG
                rxFatalError("Binding error to textbox: \(error)")
#endif
                break
            case .Completed:
                break
            }
        }
    }
}

extension UILabel {
}