//
//  UIPageControl+Rx.swift
//  RxCocoa
//
//  Created by Francesco Puntillo on 14/04/2016.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)
    
#if !RX_NO_MODULE
import RxSwift
#endif
import UIKit
    
extension Reactive where Base: UIPageControl {
    
    /// Bindable sink for `currentPage` property.
    public var currentPage: UIBindingObserver<Base, Int> {
        return UIBindingObserver(UIElement: self.base) { controller, page in
            controller.currentPage = page
        }
    }
    
    /// Bindable sink for `numberOfPages` property.
    public var numberOfPages: UIBindingObserver<Base, Int> {
        return UIBindingObserver(UIElement: self.base) { controller, page in
            controller.numberOfPages = page
        }
    }
    
}
    
#endif
