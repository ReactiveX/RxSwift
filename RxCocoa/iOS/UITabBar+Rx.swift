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

extension UITabBar {

    /**
     Bindable sink for `barStyle` property.
     */
    public var rx_barStyle: AnyObserver<UIBarStyle> {
        return UIBindingObserver(UIElement: self) { tabBar, barStyle in
            tabBar.barStyle = barStyle
        }.asObserver()
    }

}

#endif
