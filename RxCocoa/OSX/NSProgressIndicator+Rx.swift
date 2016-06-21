//
//  NSProgressIndicator+Rx.swift
//  Rx
//
//  Created by Junior B. on 21/06/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation
import Cocoa
#if !RX_NO_MODULE
import RxSwift
#endif


extension NSProgressIndicator {

    /**
    Bindable sink for `progress` property
    */
    public var rx_progress: AnyObserver<Double> {
        return UIBindingObserver(UIElement: self) { progressView, progress in
            progressView.doubleValue = progress
        }.asObserver()
    }

}
