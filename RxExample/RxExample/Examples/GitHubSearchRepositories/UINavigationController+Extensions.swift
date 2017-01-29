//
//  UINavigationController+Extensions.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 12/13/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

struct Colors {
    static let OfflineColor = UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0)
    static let OnlineColor = nil as UIColor?
}

extension Reactive where Base: UINavigationController {
    var serviceState: UIBindingObserver<Base, ServiceState?> {
        return UIBindingObserver(UIElement: base) { navigationController, maybeServiceState in
            // if nil is being bound, then don't change color, it's not perfect, but :)
            if let serviceState = maybeServiceState {
                let isOffline = serviceState == .offline

                navigationController.navigationBar.backgroundColor = isOffline
                    ? Colors.OfflineColor
                    : Colors.OnlineColor
            }
        }
    }
}
