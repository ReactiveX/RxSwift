//
//  UIButton+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)

import RxSwift
import UIKit

extension Reactive where Base: UIButton {
    
    /// Reactive wrapper for `TouchUpInside` control event.
    public var tap: ControlEvent<Void> {
        controlEvent(.touchUpInside)
    }
}

#endif

#if os(tvOS)

import RxSwift
import UIKit

extension Reactive where Base: UIButton {

    /// Reactive wrapper for `PrimaryActionTriggered` control event.
    public var primaryAction: ControlEvent<Void> {
        controlEvent(.primaryActionTriggered)
    }

}

#endif

#if os(iOS) || os(tvOS)

import RxSwift
import UIKit

extension UIControl.State: CaseIterable{
    public static var allCases: [UIControl.State] {
        return [.normal, .highlighted, .disabled, .selected, .focused, .application, .reserved]

    }
}

extension Reactive where Base: UIButton {
    /// Reactive wrapper for `setTitle(_:for:)`
    public func title(for controlState: UIControl.State...) -> Binder<String?> {
        Binder(self.base) { button, title in
            controlState.forEach{button.setTitle(title, for: $0)}
        }
    }
    /// Reactive wrapper for `setTitle(_:for:)`
    public func title(for controlState: [UIControl.State] = []) -> Binder<String?> {
        Binder(self.base) { button, title in
            controlState.forEach{button.setTitle(title, for: $0)}
        }
    }

    /// Reactive wrapper for `setImage(_:for:)`
    public func image(for controlState: UIControl.State...) -> Binder<UIImage?> {
        Binder(self.base) { button, image in
            controlState.forEach{button.setImage(image, for: $0)}
        }
    }
    
    /// Reactive wrapper for `setImage(_:for:)`
    public func image(for controlState: [UIControl.State] = []) -> Binder<UIImage?> {
        Binder(self.base) { button, image in
            controlState.forEach{button.setImage(image, for: $0)}
        }
    }

    /// Reactive wrapper for `setBackgroundImage(_:for:)`
    public func backgroundImage(for controlState: UIControl.State...) -> Binder<UIImage?> {
        Binder(self.base) { button, image in
            controlState.forEach{button.setBackgroundImage(image, for: $0)}
        }
    }
    
    /// Reactive wrapper for `setBackgroundImage(_:for:)`
    public func backgroundImage(for controlState: [UIControl.State] = []) -> Binder<UIImage?> {
        Binder(self.base) { button, image in
            controlState.forEach{button.setBackgroundImage(image, for: $0)}
        }
    }
    
}
#endif

#if os(iOS) || os(tvOS)
    import RxSwift
    import UIKit
    
    extension Reactive where Base: UIButton {
        /// Reactive wrapper for `setAttributedTitle(_:controlState:)`
        public func attributedTitle(for controlState: UIControl.State = []) -> Binder<NSAttributedString?> {
            return Binder(self.base) { button, attributedTitle -> Void in
                button.setAttributedTitle(attributedTitle, for: controlState)
            }
        }
    }
#endif
