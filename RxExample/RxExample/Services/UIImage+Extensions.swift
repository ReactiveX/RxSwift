//
//  UIImage+Extensions.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 11/1/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if os(iOS)
import UIKit
#endif

extension Image {
    func forceLazyImageDecompression() -> Image {
        #if os(iOS)
        UIGraphicsBeginImageContext(CGSizeMake(1, 1))
        self.drawAtPoint(CGPointZero)
        UIGraphicsEndImageContext()
        #endif
        return self
    }
}