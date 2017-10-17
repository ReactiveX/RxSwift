//
//  UIImageView+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 4/1/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

#if !RX_NO_MODULE
import RxSwift
#endif
import UIKit

extension Reactive where Base: UIImageView {
    
    /// Bindable sink for `image` property.
    public var image: Binder<UIImage?> {
        return Binder(base) { imageView, image in
            imageView.image = image
        }
    }
}

#endif
