//
//  UIButton+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

extension UIButton {
    public var rx_tap: Observable<Void> {
		return rx_controlEvents(.TouchUpInside)
    }
}