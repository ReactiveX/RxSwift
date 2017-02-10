//
//  UIButton+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)

#if !RX_NO_MODULE
import RxSwift
#endif
import UIKit

extension Reactive where Base: UIButton {
    
    /// Reactive wrapper for `TouchUpInside` control event.
    public var tap: ControlEvent<Void> {
        return controlEvent(.touchUpInside)
    }
}

#endif

#if os(tvOS)

#if !RX_NO_MODULE
    import RxSwift
#endif
import UIKit

extension Reactive where Base: UIButton {

    /// Reactive wrapper for `PrimaryActionTriggered` control event.
    public var primaryAction: ControlEvent<Void> {
        return controlEvent(.primaryActionTriggered)
    }

}

#endif

#if os(iOS) || os(tvOS)

#if !RX_NO_MODULE
    import RxSwift
#endif
    import UIKit

extension Reactive where Base: UIButton {
    
    /// Reactive wrapper for `setTitle(_:controlState:)`
    public func title(for controlState: UIControlState = []) -> UIBindingObserver<Base, String?> {
        return UIBindingObserver<Base, String?>(UIElement: self.base) { (button, title) -> () in
            button.setTitle(title, for: controlState)
        }
    }
    
}
#endif

#if os(iOS) || os(tvOS)
    
#if !RX_NO_MODULE
    import RxSwift
#endif
    import UIKit
    
    extension Reactive where Base: UIButton {
        
        /// Reactive wrapper for `setAttributedTitle(_:controlState:)`
        public func attributedTitle(for controlState: UIControlState = []) -> UIBindingObserver<Base, NSAttributedString?> {
            return UIBindingObserver<Base, NSAttributedString?>(UIElement: self.base) { (button, attributedTitle) -> () in
                button.setAttributedTitle(attributedTitle, for: controlState)
            }
        }
        
    }
#endif
