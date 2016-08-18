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

extension Reactive where Base: UIButton {
    
    /**
    Reactive wrapper for `TouchUpInside` control event.
    */
    public var tap: ControlEvent<Void> {
        return controlEvent(.touchUpInside)
    }
}

#endif

#if os(tvOS)

import Foundation
#if !RX_NO_MODULE
    import RxSwift
#endif
import UIKit

extension Reactive where Base: UIButton {

    /**
     Reactive wrapper for `PrimaryActionTriggered` control event.
     */
    public var primaryAction: ControlEvent<Void> {
        return controlEvent(.primaryActionTriggered)
    }

}

#endif

#if os(iOS) || os(tvOS)

    import Foundation
#if !RX_NO_MODULE
    import RxSwift
#endif
    import UIKit

extension Reactive where Base: UIButton {
    /**
     Reactive wrapper for `setTitle(_:controlState:)`
     */
    public func title(controlState: UIControlState = []) -> AnyObserver<String?> {
        return UIBindingObserver<UIButton, String?>(UIElement: self.base) { (button, title) -> () in
            button.setTitle(title, for: controlState)
        }.asObserver()
    }
}
#endif
