//
//  UIAlertAction+Rx.swift
//  Rx
//
//  Created by Andrew Breckenridge on 5/7/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

#if os(iOS) || os(tvOS)

import Foundation
import UIKit
    
#if !RX_NO_MODULE
import RxSwift
#endif

extension UIAlertAction {

    /**
     Bindable sink for `enabled` property.
     */
    public var rx_enabled: AnyObserver<Bool> {
        return UIBindingObserver(UIElement: self) { alertAction, value in
            alertAction.enabled = value
        }.asObserver()
    }
    
}
    
#endif
