//
//  UINavigationItem+Rx.swift
//  RxCocoa
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
    
extension Reactive where Base: UINavigationItem {
    /**
    Bindable sink for `title` property.
    */
    public var title: UIBindingObserver<Base, String?> {
        return UIBindingObserver(UIElement: self.base) { navigationItem, text in
            navigationItem.title = text
        }
    }
        
}
    
#endif
