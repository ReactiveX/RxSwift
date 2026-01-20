//
//  UIImageView+Extensions.swift
//  RxExample
//
//  Created by carlos on 28/5/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit

extension UIImageView {
    func makeRoundedCorners(_ radius: CGFloat) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }

    func makeRoundedCorners() {
        makeRoundedCorners(frame.size.width / 2)
    }
}
