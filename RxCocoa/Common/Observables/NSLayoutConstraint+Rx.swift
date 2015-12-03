//
//  NSLayoutConstraint+Rx.swift
//  Rx
//
//  Created by Jason Pepas on 11/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

#if !RX_NO_MODULE
    import RxSwift
#endif

extension NSLayoutConstraint
{
    var rx_constant: Observable<CGFloat?> {
        return rx_observeWeakly(CGFloat.self, "constant")
    }
}
