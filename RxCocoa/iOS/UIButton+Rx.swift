//
//  UIButton+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(visionOS)

import RxSwift
import UIKit

public extension Reactive where Base: UIButton {
    /// Reactive wrapper for `TouchUpInside` control event.
    var tap: ControlEvent<Void> {
        controlEvent(.touchUpInside)
    }
}

#endif

#if os(tvOS)

import RxSwift
import UIKit

public extension Reactive where Base: UIButton {
    /// Reactive wrapper for `PrimaryActionTriggered` control event.
    var primaryAction: ControlEvent<Void> {
        controlEvent(.primaryActionTriggered)
    }
}

#endif

#if os(iOS) || os(tvOS) || os(visionOS)

import RxSwift
import UIKit

public extension Reactive where Base: UIButton {
    /// Reactive wrapper for `setTitle(_:for:)`
    func title(for controlState: UIControl.State = []) -> Binder<String?> {
        Binder(base) { button, title in
            button.setTitle(title, for: controlState)
        }
    }

    /// Reactive wrapper for `setImage(_:for:)`
    func image(for controlState: UIControl.State = []) -> Binder<UIImage?> {
        Binder(base) { button, image in
            button.setImage(image, for: controlState)
        }
    }

    /// Reactive wrapper for `setBackgroundImage(_:for:)`
    func backgroundImage(for controlState: UIControl.State = []) -> Binder<UIImage?> {
        Binder(base) { button, image in
            button.setBackgroundImage(image, for: controlState)
        }
    }
}
#endif

#if os(iOS) || os(tvOS) || os(visionOS)
import RxSwift
import UIKit

public extension Reactive where Base: UIButton {
    /// Reactive wrapper for `setAttributedTitle(_:controlState:)`
    func attributedTitle(for controlState: UIControl.State = []) -> Binder<NSAttributedString?> {
        Binder(base) { button, attributedTitle in
            button.setAttributedTitle(attributedTitle, for: controlState)
        }
    }
}
#endif
