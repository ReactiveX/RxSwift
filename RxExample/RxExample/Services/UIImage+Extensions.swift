//
//  UIImage+Extensions.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 11/1/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)
import UIKit
#endif

extension Image {
    func forceLazyImageDecompression() -> Image {
        #if os(iOS)
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        self.draw(at: CGPoint.zero)
        UIGraphicsEndImageContext()
        #endif
        return self
    }
}
