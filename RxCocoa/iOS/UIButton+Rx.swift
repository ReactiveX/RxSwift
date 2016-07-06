//
//  UIButton+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import UIKit

extension UIButton {
    
    /**
    Reactive wrapper for `TouchUpInside` control event.
    */
    public var rx_tap: ControlEvent<Void> {
        return rx_controlEvent(.touchUpInside)
    }
}

#endif

#if os(tvOS)

import Foundation
#if !RX_NO_MODULE
    import RxSwift
#endif
import UIKit

extension UIButton {

    /**
     Reactive wrapper for `PrimaryActionTriggered` control event.
     */
    public var rx_primaryAction: ControlEvent<Void> {
        return rx_controlEvent(.primaryActionTriggered)
    }

}

#endif

#if os(iOS) || os(tvOS)

    import Foundation
#if !RX_NO_MODULE
    import RxSwift
#endif
    import UIKit

extension UIButton {
    /**
     Reactive wrapper for `setTitle(_:controlState:)`
     */
    public func rx_title(controlState: UIControlState = []) -> AnyObserver<String?> {
        return UIBindingObserver<UIButton, String?>(UIElement: self) { (button, title) -> () in
            button.setTitle(title, for: controlState)
        }.asObserver()
    }
}
#endif
