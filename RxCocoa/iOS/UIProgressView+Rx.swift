//
//  UIProgressView+Rx.swift
//  Rx
//
//  Created by Samuel Bae on 2/27/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import UIKit

extension UIProgressView {

    /**
    Bindable sink for `progress` property
    */
    public var rx_progress: AnyObserver<Float> {
        return UIBindingObserver(UIElement: self) { progressView, progress in
            progressView.progress = progress
        }.asObserver()
    }

}

#endif