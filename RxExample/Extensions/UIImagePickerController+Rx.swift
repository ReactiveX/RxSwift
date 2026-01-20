//
//  UIImagePickerController+Rx.swift
//  RxExample
//
//  Created by Segii Shulga on 1/4/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)

import RxCocoa
import RxSwift
import UIKit

public extension Reactive where Base: UIImagePickerController {
    /**
     Reactive wrapper for `delegate` message.
     */
    var didFinishPickingMediaWithInfo: Observable<[UIImagePickerController.InfoKey: AnyObject]> {
        delegate
            .methodInvoked(#selector(UIImagePickerControllerDelegate.imagePickerController(_:didFinishPickingMediaWithInfo:)))
            .map { a in
                try castOrThrow([UIImagePickerController.InfoKey: AnyObject].self, a[1])
            }
    }

    /**
     Reactive wrapper for `delegate` message.
     */
    var didCancel: Observable<Void> {
        delegate
            .methodInvoked(#selector(UIImagePickerControllerDelegate.imagePickerControllerDidCancel(_:)))
            .map { _ in () }
    }
}

#endif

private func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }

    return returnValue
}
