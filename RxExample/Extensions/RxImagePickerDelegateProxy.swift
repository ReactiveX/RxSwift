//
//  RxImagePickerDelegateProxy.swift
//  RxExample
//
//  Created by Segii Shulga on 1/4/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)

import RxCocoa
import RxSwift
import UIKit

open class RxImagePickerDelegateProxy:
    RxNavigationControllerDelegateProxy, UIImagePickerControllerDelegate
{
    public init(imagePicker: UIImagePickerController) {
        super.init(navigationController: imagePicker)
    }
}

#endif
