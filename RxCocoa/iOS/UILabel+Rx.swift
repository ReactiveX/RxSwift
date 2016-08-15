//
//  UILabel+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 4/1/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import UIKit

extension Reactive where Base: UILabel {
    
    /**
    Bindable sink for `text` property.
    */
    public var text: AnyObserver<String?> {
        return UIBindingObserver(UIElement: self.base) { label, text in
            label.text = text
        }.asObserver()
    }

    /**
    Bindable sink for `attributedText` property.
    */
    public var attributedText: AnyObserver<NSAttributedString?> {
        return UIBindingObserver(UIElement: self.base) { label, text in
            label.attributedText = text
        }.asObserver()
    }
    
}

#endif
