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
    
    public var touchDown: ControlEvent<Void> {
        return controlEvent(.touchDown)
    }
    
    public var touchDownRepeat: ControlEvent<Void> {
        return controlEvent(.touchDownRepeat)
    }
    
    public var touchDragInside: ControlEvent<Void> {
        return controlEvent(.touchDragInside)
    }
    
    public var touchDragOutside: ControlEvent<Void> {
        return controlEvent(.touchDragOutside)
    }
    
    public var touchDragEnter: ControlEvent<Void> {
        return controlEvent(.touchDragEnter)
    }
    
    public var touchDragExit: ControlEvent<Void> {
        return controlEvent(.touchDragExit)
    }
    
    public var touchUpInside: ControlEvent<Void> {
        return controlEvent(.touchUpInside)
    }
    
    /// Reactive wrapper for `TouchUpInside` control event.
    public var tap: ControlEvent<Void> {
        return controlEvent(.touchUpInside)
    }
    
    public var touchUpOutside: ControlEvent<Void> {
        return controlEvent(.touchUpOutside)
    }
    
    public var touchCancel: ControlEvent<Void> {
        return controlEvent(.touchCancel)
    }
    
    public var valueChanged: ControlEvent<Void> {
        return controlEvent(.valueChanged)
    }
    
    public var primaryActionTriggered: ControlEvent<Void> {
        return controlEvent(.primaryActionTriggered)
    }
    
    public var editingDidBegin: ControlEvent<Void> {
        return controlEvent(.editingDidBegin)
    }
    
    public var editingChanged: ControlEvent<Void> {
        return controlEvent(.editingChanged)
    }
    
    public var editingDidEnd: ControlEvent<Void> {
        return controlEvent(.editingDidEnd)
    }
    
    public var editingDidEndOnExit: ControlEvent<Void> {
        return controlEvent(.editingDidEndOnExit)
    }
    
    public var allTouchEvents: ControlEvent<Void> {
        return controlEvent(.allTouchEvents)
    }
    
    public var allEditingEvents: ControlEvent<Void> {
        return controlEvent(.allEditingEvents)
    }
    
    public var applicationReserved: ControlEvent<Void> {
        return controlEvent(.applicationReserved)
    }
    
    public var systemReserved: ControlEvent<Void> {
        return controlEvent(.systemReserved)
    }
    
    public var allEvents: ControlEvent<Void> {
        return controlEvent(.allEvents)
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
    
    /// Reactive wrapper for `setTitle(_:for:)`
    public func title(for controlState: UIControlState = []) -> UIBindingObserver<Base, String?> {
        return UIBindingObserver<Base, String?>(UIElement: self.base) { (button, title) -> () in
            button.setTitle(title, for: controlState)
        }
    }

    /// Reactive wrapper for `setImage(_:for:)`
    public func image(for controlState: UIControlState = []) -> UIBindingObserver<Base, UIImage?> {
        return UIBindingObserver<Base, UIImage?>(UIElement: self.base) { (button, image) -> () in
            button.setImage(image, for: controlState)
        }
    }

    /// Reactive wrapper for `setBackgroundImage(_:for:)`
    public func backgroundImage(for controlState: UIControlState = []) -> UIBindingObserver<Base, UIImage?> {
        return UIBindingObserver<Base, UIImage?>(UIElement: self.base) { (button, image) -> () in
            button.setBackgroundImage(image, for: controlState)
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
