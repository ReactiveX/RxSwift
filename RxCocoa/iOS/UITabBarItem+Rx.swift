//
//  UITabBarItem+Rx.swift
//  Rx
//
//  Created by Mateusz Derks on 04/03/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)
    
    import Foundation
    import UIKit
#if !RX_NO_MODULE
    import RxSwift
#endif
    
extension UITabBarItem {
    
    /**
     Bindable sink for `badgeValue` property.
     */
    public var rx_badgeValue: AnyObserver<String?> {
        return UIBindingObserver(UIElement: self) { tabBarItem, badgeValue in
            tabBarItem.badgeValue = badgeValue
        }.asObserver()
    }
    
}
    
#endif
