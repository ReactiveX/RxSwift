//
//  UIAlertAction+Rx.swift
//  RxCocoa
//
//  Created by Andrew Breckenridge on 5/7/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import Foundation
import UIKit
    
#if !RX_NO_MODULE
import RxSwift
#endif

extension Reactive where Base: UIAlertAction {

    /// Bindable sink for `enabled` property.
    public var isEnabled: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { alertAction, value in
            alertAction.isEnabled = value
        }
    }
    
}
    
#endif
