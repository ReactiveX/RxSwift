//
//  UITabBarItem+Rx.swift
//  RxCocoa
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
    
extension Reactive where Base: UITabBarItem {
    
    /// Bindable sink for `badgeValue` property.
    public var badgeValue: UIBindingObserver<Base, String?> {
        return UIBindingObserver(UIElement: self.base) { tabBarItem, badgeValue in
            tabBarItem.badgeValue = badgeValue
        }
    }
    
}
    
#endif
