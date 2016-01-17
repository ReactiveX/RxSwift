//
//  UIImagePickerController+RxCreate.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 1/10/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif

func dismissViewController(viewController: UIViewController, animated: Bool) {
    if viewController.isBeingDismissed() || viewController.isBeingPresented() {
        dispatch_async(dispatch_get_main_queue()) {
            dismissViewController(viewController, animated: animated)
        }

        return
    }

    if viewController.presentingViewController != nil {
        viewController.dismissViewControllerAnimated(animated, completion: nil)
    }
}

extension UIImagePickerController {
    static func rx_createWithParent(parent: UIViewController?, animated: Bool = true, configureImagePicker: (UIImagePickerController) throws -> () = { x in }) -> Observable<UIImagePickerController> {
        return Observable.create { [weak parent] observer in
            let imagePicker = UIImagePickerController()
            let dismissDisposable = imagePicker
                .rx_didCancel
                .subscribeNext({ [weak imagePicker] in
                    guard let imagePicker = imagePicker else {
                        return
                    }
                    dismissViewController(imagePicker, animated: animated)
                })
            
            do {
                try configureImagePicker(imagePicker)
            }
            catch let error {
                observer.on(.Error(error))
                return NopDisposable.instance
            }

            guard let parent = parent else {
                observer.on(.Completed)
                return NopDisposable.instance
            }

            parent.presentViewController(imagePicker, animated: animated, completion: nil)
            observer.on(.Next(imagePicker))
            
            return CompositeDisposable(dismissDisposable, AnonymousDisposable {
                    dismissViewController(imagePicker, animated: animated)
                })
        }
    }
}