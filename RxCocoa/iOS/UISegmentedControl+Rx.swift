//
//  UISegmentedControl+Rx.swift
//  RxCocoa
//
//  Created by Carlos García on 8/7/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(visionOS)

import RxSwift
import UIKit

public extension Reactive where Base: UISegmentedControl {
    /// Reactive wrapper for `selectedSegmentIndex` property.
    var selectedSegmentIndex: ControlProperty<Int> {
        value
    }

    /// Reactive wrapper for `selectedSegmentIndex` property.
    var value: ControlProperty<Int> {
        base.rx.controlPropertyWithDefaultEvents(
            getter: { segmentedControl in
                segmentedControl.selectedSegmentIndex
            }, setter: { segmentedControl, value in
                segmentedControl.selectedSegmentIndex = value
            }
        )
    }

    /// Reactive wrapper for `setEnabled(_:forSegmentAt:)`
    func enabledForSegment(at index: Int) -> Binder<Bool> {
        Binder(base) { segmentedControl, segmentEnabled in
            segmentedControl.setEnabled(segmentEnabled, forSegmentAt: index)
        }
    }

    /// Reactive wrapper for `setTitle(_:forSegmentAt:)`
    func titleForSegment(at index: Int) -> Binder<String?> {
        Binder(base) { segmentedControl, title in
            segmentedControl.setTitle(title, forSegmentAt: index)
        }
    }

    /// Reactive wrapper for `setImage(_:forSegmentAt:)`
    func imageForSegment(at index: Int) -> Binder<UIImage?> {
        Binder(base) { segmentedControl, image in
            segmentedControl.setImage(image, forSegmentAt: index)
        }
    }
}

#endif
