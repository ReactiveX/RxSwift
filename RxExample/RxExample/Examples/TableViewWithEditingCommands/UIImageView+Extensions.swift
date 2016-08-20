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
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }

    func makeRoundedCorners() {
        self.makeRoundedCorners(self.frame.size.width / 2)
    }
}
