//
//  UITextView+Rx.swift
//  RxCocoa
//
//  Created by Yuta ToKoRo on 7/18/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

extension UITextView {
    public var rx_text: Observable<String> {
        return NSNotificationCenter.defaultCenter().rx_notification(UITextViewTextDidChangeNotification, object: self)
            >- map { notification -> String in
                return (notification.object as? UITextView)?.text ?? ""
            }
    }
}