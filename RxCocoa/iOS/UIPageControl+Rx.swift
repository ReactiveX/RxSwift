//
//  UIPageControl+Rx.swift
//  Rx
//
//  Created by Anurag Ajwani on 24/02/2016.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)

import Foundation
import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif

extension UIPageControl {
    
    /**
     Reactive wrapper for `numberOfPages` property.
     */
    public var rx_numberOfPages: ControlProperty<Int> {
        return UIControl.rx_value(
            self,
            getter: { pageControl in
                pageControl.numberOfPages
            }, setter: { pageControl, value in
                pageControl.numberOfPages = value
                pageControl.updateCurrentPageDisplay()
            }
        )
    }
    
    /**
     Reactive wrapper for `currentPage` property.
     */
    public var rx_currentPage: ControlProperty<Int> {
        return UIControl.rx_value(
            self,
            getter: { pageControl in
                pageControl.currentPage
            }, setter: { pageControl, value in
                pageControl.currentPage = value
                pageControl.updateCurrentPageDisplay()
            }
        )
    }
}
    
#endif