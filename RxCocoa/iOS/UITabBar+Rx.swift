//
//  UITabBar+Rx.swift
//  Rx
//
//  Created by Jesse Farless on 5/13/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)
import Foundation
import UIKit

#if !RX_NO_MODULE
import RxSwift
#endif

/**
 iOS only
 */
#if os(iOS)
extension UITabBar {

    /**
     Bindable sink for `barStyle` property.
     */
    public var rx_barStyle: AnyObserver<UIBarStyle> {
        return UIBindingObserver(UIElement: self) { tabBar, barStyle in
            tabBar.barStyle = barStyle
        }.asObserver()
    }

    /**
     Bindable sink for `itemPositioning` property.
     */
    public var rx_itemPositioning: AnyObserver<UITabBarItemPositioning> {
        return UIBindingObserver(UIElement: self) { tabBar, itemPositioning in
            tabBar.itemPositioning = itemPositioning
        }.asObserver()
    }

}
#endif

/**
 iOS and tvOS
 */
extension UITabBar {
    
    /**
     Bindable sink for `items` property.
     */
    public var rx_items: AnyObserver<[UITabBarItem]?> {
        return UIBindingObserver(UIElement: self) { tabBar, items in
            tabBar.items = items
        }.asObserver()
    }
    
    /**
     Bindable sink for `translucent` property.
     */
    public var rx_translucent: AnyObserver<Bool> {
        return UIBindingObserver(UIElement: self) { tabBar, translucent in
            tabBar.translucent = translucent
        }.asObserver()
    }

    /**
     Bindable sink for `barTintColor` property.
     */
    public var rx_barTintColor: AnyObserver<UIColor?> {
        return UIBindingObserver(UIElement: self) { tabBar, barTintColor in
            tabBar.barTintColor = barTintColor
        }.asObserver()
    }

    /**
     Bindable sink for `itemSpacing` property.
     */
    public var rx_itemSpacing: AnyObserver<CGFloat> {
        return UIBindingObserver(UIElement: self) { tabBar, itemSpacing in
            tabBar.itemSpacing = itemSpacing
        }.asObserver()
    }

    /**
     Bindable sink for `itemWidth` property.
     */
    public var rx_itemWidth: AnyObserver<CGFloat> {
        return UIBindingObserver(UIElement: self) { tabBar, itemWidth in
            tabBar.itemWidth = itemWidth
        }.asObserver()
    }

    /**
     Bindable sink for `tintColor` property.
     */
    public var rx_tintColor: AnyObserver<UIColor> {
        return UIBindingObserver(UIElement: self) { tabBar, tintColor in
            tabBar.tintColor = tintColor
        }.asObserver()
    }

    /**
     Bindable sink for `backgroundImage` property.
     */
    public var rx_backgroundImage: AnyObserver<UIImage?> {
        return UIBindingObserver(UIElement: self) { tabBar, backgroundImage in
            tabBar.backgroundImage = backgroundImage
        }.asObserver()
    }

    /**
     Bindable sink for `shadowImage` property.
     */
    public var rx_shadowImage: AnyObserver<UIImage?> {
        return UIBindingObserver(UIElement: self) { tabBar, shadowImage in
            tabBar.shadowImage = shadowImage
        }.asObserver()
    }

    /**
     Bindable sink for `selectionIndicatorImage` property.
     */
    public var rx_selectionIndicatorImage: AnyObserver<UIImage?> {
        return UIBindingObserver(UIElement: self) { tabBar, selectionIndicatorImage in
            tabBar.selectionIndicatorImage = selectionIndicatorImage
        }.asObserver()
    }

}

#endif
