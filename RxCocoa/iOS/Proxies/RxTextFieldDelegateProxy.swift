//
//  RxTextFieldDelegateProxy.swift
//  RxCocoa
//
//  Created by Andrew Breckenridge on 11/6/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import Foundation
import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif

public class RxTextFieldDelegateProxy
    : DelegateProxy
    , UITextFieldDelegate
    , DelegateProxyType {

    public static func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let textField: UITextField = castOrFatalError(object)
        textField.delegate = castOptionalOrFatalError(delegate)
    }

    public static func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let textField: UITextField = castOrFatalError(object)
        return textField.delegate
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self._methodInvoked(#selector(UITextFieldDelegate.textFieldShouldReturn(_:)), withArguments: [textField])
        return self._forwardToDelegate?.textFieldShouldReturn(textField) ?? true
    }

}



#endif
