//
//  UINavigationItem+Rx.swift
//  Rx
//
//  Created by kumapo on 2016/05/09.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)
    
import Foundation
import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif
    
extension UINavigationItem {
    /**
    Bindable sink for `title` property.
    */
    public var rx_title: AnyObserver<String?> {
        return UIBindingObserver(UIElement: self) { navigationItem, text in
            navigationItem.title = text
            }.asObserver()
    }
        
}
    
#endif