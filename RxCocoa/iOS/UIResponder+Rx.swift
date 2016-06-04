//
//  UIResponder+Rx.swift
//  RX
//
//  Created by Hernan G. Gonzalez on 3/6/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import UIKit

extension UIResponder {

	/**
	Bindable sink for `resignFirstResponder`.
	*/
	public var rx_resignFirstResponder: AnyObserver<Void> {
		return UIBindingObserver(UIElement: self) { control, _ in
			control.resignFirstResponder()
		}.asObserver()
	}

	/**
	Bindable sink for `becomeFirstResponder`.
	*/
	public var rx_becomeFirstResponder: AnyObserver<Void> {
		return UIBindingObserver(UIElement: self) { control, _ in
			control.becomeFirstResponder()
		}.asObserver()
	}

}

#endif
