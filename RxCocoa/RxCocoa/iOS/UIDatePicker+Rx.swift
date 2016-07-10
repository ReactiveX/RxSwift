//
//  UIDatePicker+Rx.swift
//  RxCocoa
//
//  Created by Daniel Tartaglia on 5/30/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

extension UIDatePicker {
    
    public var rx_date: Observable<NSDate> {
        return rx_controlEvents(.ValueChanged) >- map { _ in self.date }
    }

}