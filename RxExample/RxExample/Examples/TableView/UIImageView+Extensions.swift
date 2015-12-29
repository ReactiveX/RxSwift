//
//  UIImageView+Extensions.swift
//  RxExample
//
//  Created by carlos on 28/5/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func makeRoundedCorners(radius: CGFloat) {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.layer.borderColor = UIColor.darkGrayColor().CGColor
        self.layer.borderWidth = radius
        self.layer.masksToBounds = true
    }
    
}
